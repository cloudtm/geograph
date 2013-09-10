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
  class RandomVenueOwner < Behaviors::RandomMover
    include ActionsForBehaviors

    def initialize
      super
    end

    def next_action
      next_action = nil
      behavior_progress
      if @agent.status == 'running'
	Madmass.logger.debug "==[#{self}] ---"
        advance_pos
        if rand(10) == 0
          name = rand(36**10).to_s(36)
          Madmass.logger.debug "==[#{self}] creating venue '#{name}' at #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = create_venue_action({ :name => name })
        end
      end
      next_action
    end

  end
end
