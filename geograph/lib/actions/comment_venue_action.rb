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


class Actions::CommentVenueAction < Madmass::Action::Action
  action_params :venue_id, :latitude, :longitude, :user

  def initialize params
    super
  end

  def execute
    CloudTm::DomainRootCache.readonly_action = false
    @venue = CloudTm::Venue.find_by_id(@parameters[:venue_id])
    if @venue
      @new_comment = CloudTm::Comment.create(
        :locality_key => CloudTm::VenueLandmark.locality_key,
        :locality_value => CloudTm::VenueLandmark.locality_value(@parameters[:latitude], @parameters[:longitude]),
        :comment => "This is comment #{@venue.comments.size + 1} to venue #{@venue.id} '#{@venue.name ? @venue.name[0..10] : ''}'"
      )
      @venue.addComments @new_comment
      @venue.location.body += "This is comment #{@venue.comments.size + 1}: blah blah blah<br>"
      Madmass.logger.debug "==[#{self}] commented venue #{@venue.id} with '#{@new_comment.comment}'"
    else
      Madmass.logger.error "==[#{self}] Cannot find venue with id = #{@parameters[:venue_id]}"
    end
  end

  def build_result
    p = Madmass::Perception::Percept.new(self)
   
    if @venue and @new_comment 
      p.data = {
        :venue_id => @venue.id,
        :comment => @new_comment.comment
      }
    end

    Madmass.current_perception << p
  end

end
