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
  class RandomFoursquareUser < Behaviors::RandomMover
    include ActionsForBehaviors

    def initialize
      super
      @current_venue_id = nil
      @sub_behavior_step = 0
    end

    # behavior: (move* get_nearby_venues checkin (comment_venue|like_venue|get_curr_friends_at_venue|get_past_friends_at_venue)*)*

    def next_action
      next_action = nil
      behavior_progress
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        if @sub_behavior_step % 4 == 0
          # move*
          advance_pos
          Madmass.logger.debug "==[#{self}] moving to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          if rand(10) == 0
            @sub_behavior_step += 1
          end
        elsif @sub_behavior_step % 4 == 1
          # get_nearby_venues
          Madmass.logger.debug "==[#{self}] getting venues near to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = get_nearby_venues_action
          @sub_behavior_step += 1
        elsif @sub_behavior_step % 4 == 2
#          @sub_behavior_step = 0
          if not Madmass.current_perception[0] or not Madmass.current_perception[0].data[:nearby_venues] or Madmass.current_perception[0].data[:nearby_venues].empty?
            nearby_venues = Madmass.current_perception[0].data[:nearby_venues]
            Madmass.logger.debug "==[#{self}] no venue found nearby: nothing to do"
            @sub_behavior_step = 0
          else
            Madmass.logger.debug "==[#{self}] found #{nearby_venues.size} venues nearby"
            venue = nearby_venues.sample
            Madmass.logger.debug "==[#{self}] randomly chosen this: #{venue.inspect}, checking in"
            @current_venue_id = venue[:id]
            next_action = checkin_action({ :venue_id => @current_venue_id })
            @sub_behavior_step += 1
          end
        elsif @sub_behavior_step % 4 == 3
          # (comment_venue | like_venue | get_curr_friends_at_venue | get_past_friends_at_venue)*
          if rand(4) == 0
            next_action = comment_venue_action({ :venue_id => @current_venue_id })
            Madmass.logger.debug "==[#{self}] commenting venue #{@current_venue_id}"
          elsif rand(4) == 1
            next_action = like_venue_action({ :venue_id => @current_venue_id })
            Madmass.logger.debug "==[#{self}] liking venue #{@current_venue_id}"
          elsif rand(4) == 2
            next_action = get_curr_friends_at_venue_action({ :venue_id => @current_venue_id })
            Madmass.logger.debug "==[#{self}] getting current friends at venue #{@current_venue_id}"
          elsif rand(4) == 3
            next_action = get_past_friends_at_venue_action({ :venue_id => @current_venue_id })
            Madmass.logger.debug "==[#{self}] getting past friends at venue #{@current_venue_id}"
          end
          if rand(10) == 0
            @sub_behavior_step = 0
          end
        end
      end
      next_action
    end
  end
end
