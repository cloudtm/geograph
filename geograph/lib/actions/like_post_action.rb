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


class Actions::LikePostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :post_id, :user

  def initialize params
    super
  end

  def execute
    CloudTm::DomainRootCache.readonly_action = false
    @post = CloudTm::Post.find_by_id(@parameters[:post_id])
    if @post
      if not @post.likes
        @post.likes = 1
      else
        @post.likes += 1
      end
      @post.location.body += " (like) "
      Madmass.logger.debug "==[#{self}] Liked post #{@post.id} (currently #{@post.likes} likes)"
    else
      Madmass.logger.debug "==[#{self}] cannot find post with id #{@parameters[:post_id]}"
    end
  end

  def build_result
    p = Madmass::Perception::Percept.new(self)
   
    if @post
      p.data = {
        :post_id => @post.id,
        :likes => @post.likes
      }
    end

    Madmass.current_perception << p
  end

end
