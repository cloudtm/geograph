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
  class RandomMicroGeoBlogger < Behaviors::RandomMover
    include ActionsForBehaviors

    def initialize
      super
      @sub_behavior_step = :move
    end

    # behavior: (move* (post | get_nearby_posts (comment_post | like_post) ) )*

    def next_action
      next_action = nil
      behavior_progress
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        if @sub_behavior_step == :move
          advance_pos
          Madmass.logger.debug "==[#{self}] moving to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          if rand(5) == 0
            if rand(2) == 0
              @sub_behavior_step = :post
            else
              @sub_behavior_step = :get_nearby_posts
            end
          end
        elsif @sub_behavior_step == :post
          Madmass.logger.debug "==[#{self}] posting near to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = geo_post_action
          @sub_behavior_step = :move
        elsif @sub_behavior_step == :get_nearby_posts
          Madmass.logger.debug "==[#{self}] getting posts near to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = get_nearby_posts_action
          if rand(2) == 0
            @sub_behavior_step = :comment_post
          else
            @sub_behavior_step = :like_post
          end 
        elsif @sub_behavior_step == :comment_post or @sub_behavior_step == :like_post
          nearby_posts = Madmass.current_perception[0]
          nearby_posts = nearby_posts.data[:nearby_posts] if nearby_posts	# FIXME sometimes current_perception[0] is nil
          if not nearby_posts or nearby_posts.empty?
            Madmass.logger.debug "==[#{self}] no post found nearby: nothing to do"
            @sub_behavior_step = :move
          else
            Madmass.logger.debug "==[#{self}] found #{nearby_posts.size} posts nearby"
            post = nearby_posts.sample
            Madmass.logger.debug "==[#{self}] randomly chosen this: #{post.inspect}"
            if rand(4) == 0
              next_action = comment_post_action({ :post_id => post[:id] })
              Madmass.logger.debug "==[#{self}] commenting post #{post[:id]}"
            else
              next_action = like_post_action({ :post_id => post[:id] })
              Madmass.logger.debug "==[#{self}] liking post #{post[:id]}"
            end
            @sub_behavior_step = :move
          end
        end
      end
      next_action
    end

  end
end
