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

# Selects at random a GPX route, and executes it from the beginning to the end.
require "#{Rails.root}/lib/actions_for_behaviors"

module Behaviors
  class RandomNoop < Madmass::AgentFarm::Agent::Behavior
    include ActionsForBehaviors

    def initialize
      @current_route = nil
      @position_in_route = 0
      @current_pos = nil
      @behavior_step = 0
      @was_running = false
    end

    def behavior_progress
      if @agent.status == 'running'
        if not @was_running
          @behavior_step = 0
        else
          @behavior_step += 1
        end 
        @was_running = true
      elsif @agent.status == 'stopped'
        @was_running = false
      end 
    end

    def choose!
      nil
    end

    def defined?
      true
    end

    def next_action
      nil
    end

    def last_wish
      destroy_agent_action
    end

  end

end

