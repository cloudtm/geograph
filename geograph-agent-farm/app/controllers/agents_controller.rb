###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Largo Alfredo Oriani 12
# 00152 Rome, Italy
#
###############################################################################
###############################################################################

class AgentsController < ApplicationController
    include Madmass::Transaction::TxMonitor


    before_filter :authenticate_agent
    around_filter :tx_monitor
    respond_to :html, :js


    def index
      @agent_groups = CloudTm::AgentGroup.all
    end

    def refresh_time
      agent_groups = CloudTm::AgentGroup.all
      @last_execution_times = {}
      agent_groups.each do |group|
        group.getAgents.each do |agent|
          @last_execution_times[agent.getExternalId] = {
            :delay => group.delay,
            :last_execution => (agent.execution_time ? agent.execution_time : -1)
          }
        end
      end
    end
end
