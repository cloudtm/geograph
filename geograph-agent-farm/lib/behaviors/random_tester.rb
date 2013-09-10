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

module Behaviors
  class RandomTester < Behaviors::RandomMover
    def initialize
      super
      @behavior_step = 0
      @was_running = false
    end

    def next_action
      next_action = nil
      behavior_progress
      if @agent.status == 'running'
        Madmass.logger.debug "==[#{self}] ---"
        if @behavior_step % 2 == 0
          advance_pos
          Madmass.logger.debug "==[#{self}] getting posts near to #{@current_pos[:latitude].to_f.round(5)}, #{@current_pos[:longitude].to_f.round(5)}"
          next_action = get_nearby_posts_action
        else
          nearby_posts = Madmass.current_perception[0].data[:nearby_posts]
          if not nearby_posts or nearby_posts.empty?
            Madmass.logger.debug "==[#{self}] no post found nearby: nothing to do"
          else
            Madmass.logger.debug "==[#{self}] found #{nearby_posts.size} posts nearby"
            post = nearby_posts.sample
            Madmass.logger.debug "==[#{self}] randomly chosen this: #{post.inspect}"
            next_action = comment_post_action({ :post_id => post[:id] })
          end
        end
      end
      next_action
    end


    private

    def get_nearby_posts_action opts = {}
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      result = {
        :cmd => "lard_remote",
        :data => {
          :cmd => 'actions::get_nearby_posts',
          :sync => true,
          :latitude => lat,
          :longitude => lon,
          :max_count => 10,
          :max_dist => 10000,
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.debug "==[#{self}] created get nearby posts action: \n #{result.to_yaml}\n"
      return result
    end

    def comment_post_action opts
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      post_id = opts[:post_id]
      result = {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::comment_post',
          :latitude => lat,
          :longitude => lon,
          :post_id => post_id,
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.debug "==[#{self}] created comment post action: \n #{result.to_yaml}\n"
      return result
    end

    def like_post_action opts
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      post_id = opts[:post_id]
      result = {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::like_post',
          :latitude => lat,
          :longitude => lon,
          :post_id => post_id,
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.debug "==[#{self}] created like post action: \n #{result.to_yaml}\n"
      return result
    end

  end
end
