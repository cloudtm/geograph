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
  class RandomBlogger10k < Behaviors::RandomMover
    def initialize
      super
      @posts_added = 0
    end

    NUM_OF_POSTS = 10000

    def next_action
      next_action = nil
      if @agent.status == 'running'
        batch_count = GeographOptions[:batch_add_posts][:count] || 1
        #Madmass.logger.error "Agent #{@agent.id}, posts (real) = #{@posts_added}, (saved) = #{@agent.numOfPosts}"
        if @posts_added < NUM_OF_POSTS
          next_action = geo_post_object(@current_route[@position_in_route])
          @posts_added += batch_count
          if @posts_added % 10 == 0
            @agent.numOfPosts = @posts_added
          end
          @position_in_route += 1
          @current_route = nil if @current_route[@position_in_route].nil?
        elsif @posts_added == NUM_OF_POSTS
          @agent.finished = true
          @posts_added = NUM_OF_POSTS + 1
        end
      end
      if not next_action
        sleep 1 # this avoids 100% CPU waste
      end 
      return next_action
    end

  end
end
