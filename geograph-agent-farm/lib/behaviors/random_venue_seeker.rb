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

require "#{Rails.root}/lib/behaviors/random_mover"
require "#{Rails.root}/lib/actions_for_behaviors"

module Behaviors
  class RandomVenueSeeker < Behaviors::RandomMover
    include ActionsForBehaviors

    def initialize
      super
    end

    def next_action
      next_action = nil
      behavior_progress
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        if @behavior_step % 2 == 0
          advance_pos
          Madmass.logger.debug "==[#{self}] getting venues near to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = get_nearby_venues_action
        else
          nearby_venues = Madmass.current_perception[0].data[:nearby_venues]
          if not nearby_venues or nearby_venues.empty?
            Madmass.logger.debug "==[#{self}] no venue found nearby: nothing to do"
          else
            Madmass.logger.debug "==[#{self}] found #{nearby_venues.size} venues nearby"
          end
        end
      end
      next_action
    end

  end
end
