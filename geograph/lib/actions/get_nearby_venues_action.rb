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

require 'haversine_distance.rb'

class Actions::GetNearbyVenuesAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user, :max_dist, :max_count

  def initialize params
    super
    @channels << :all
  end

  # the action effects.
  def execute
    CloudTm::DomainRootCache.readonly_action = true
    Madmass.logger.debug "==[#{self}] ---"
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    max_dist = @parameters[:max_dist]
    max_count = @parameters[:max_count] ? @parameters[:max_count] : 10
    @nearby_venues = GeographKdTreeHelper.get_nearby_locations CloudTm::VenueLandmark, lat, lon, max_count, max_dist
    @nearby_venues = @nearby_venues.map{ |l| l.venue }
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :nearby_venues => []
    }
    @nearby_venues.each do |pread|
      p.data[:nearby_venues] << {
        :id => pread.getExternalId,
        :latitude => pread.location.latitude.to_s,
        :longitude => pread.location.longitude.to_s
      }
    end

    Madmass.current_perception << p
  end

end
