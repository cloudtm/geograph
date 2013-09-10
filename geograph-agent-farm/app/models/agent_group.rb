###############################################################################
###############################################################################
#
# This file is part of GeoGraph.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Largo Alfredo Oriani 12
# 00152 Rome, Italy
#
###############################################################################
###############################################################################

class AgentGroup < ActiveRecord::Base
  attr_accessible :simulator, :sleep, :static_profile_id, :threads, :cache_id, :track_filter_type, :track_filter_value
  belongs_to :static_profile
  include Madmass::Transaction::TxMonitor


  def deploy
    group_options ={"agents_type" => simulator, "delay" => sleep, "status" => "idle", "track_filter_type" => track_filter_type, "track_filter_value" => track_filter_value }
    Madmass.logger.debug "DEPLOY: About to create group -- #{threads} agents #{group_options.inspect}--"

    tx_monitor do
      @agent_group = CloudTm::AgentGroup.create_group(threads, group_options)
      Madmass.logger.info "DEPLOY: Created agent group with id #{@agent_group.id} -- #{@agent_group.inspect}"
      self.cache_id = @agent_group.id
      save!
      Madmass.logger.debug "DEPLOY: Agentgroup Cache id saved"
    end

    tx_monitor do
      Madmass.logger.debug "DEPLOY: Retrieving agent group with cache id #{self.cache_id}"
      CloudTm::AgentGroup.boot(:agent_group_id => self.cache_id)
    end
  end

  def start
    tx_monitor do
      agent_group = CloudTm::AgentGroup.find_by_id self.cache_id
      # agent_group.update_attribute(:status, 'started')
      Madmass.logger.debug "STARTING AGENT GROUP #{agent_group.inspect}"
      if agent_group
        agent_group.start
      else
        Madmass.logger.error "DEPLOY: Could not find agent group #{self.cache_id}"
      end

    end
  end

  def shutdown
    tx_monitor do
      Madmass.logger.debug "SHUTTING DOWN AGENT GROUP #{self.cache_id}"
      agent_group = CloudTm::AgentGroup.find_by_id self.cache_id
      ##terminates all the background tasks, one per each agent of the group
      if agent_group
        agent_group.shutdown
      else
        Madmass.logger.error "DEPLOY: Could not find agent group #{self.cache_id}"
      end

    end
  end


end
