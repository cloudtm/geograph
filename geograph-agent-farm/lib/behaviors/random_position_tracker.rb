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
  class RandomPositionTracker < Behaviors::RandomMover
    include ActionsForBehaviors

    def next_action
      behavior_progress
      action = nil
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        advance_pos
        if @current_route
          action = save_user_pos_action(@current_route[@position_in_route])
          Madmass.logger.debug "==[#{self}] saving my pos: #{@position_in_route} of #{@current_route.size}"
        else
          Madmass.logger.debug "==[#{self}] restarting another route"
        end
      end
      return action
    end

  end

end

