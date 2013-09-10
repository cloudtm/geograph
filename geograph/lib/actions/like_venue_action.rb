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


class Actions::LikeVenueAction < Madmass::Action::Action
  action_params :latitude, :longitude, :venue_id, :user

  def initialize params
    super
  end

  def execute
    DomainRootCached.readonly_phase = false
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    landmark = CloudTm::VenueLandmark.find_by_coordinates(lat, lon)

    @venue = CloudTm::Venue.find_by_id(@parameters[:venue_id])
    if @venue
      if not @venue.likes
        @venue.likes = 1
      else
        @venue.likes += 1
      end
      @venue.location.body += ' (like) '
      Madmass.logger.debug "==[#{self}] Liked venue #{@venue.id} (currently #{@venue.likes} likes)"
    else
      Madmass.logger.debug "==[#{self}] cannot find venue with id #{@parameters[:venue_id]}"
    end
  end

  def build_result
    p = Madmass::Perception::Percept.new(self)
   
    if @venue
      p.data = {
        :venue_id => @venue.id,
        :likes => @venue.likes
      }
    end

    Madmass.current_perception << p
  end

end
