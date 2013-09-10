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


class Actions::ReadPostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user

  def initialize params
    super
    @channels << :all
  end


  # the action effects.
  def execute
    CloudTm::DomainRootCache.readonly_action = true
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])

    max_dist = @parameters[:max_dist] ? @parameters[:max_dist] : 10000
    max_count = @parameters[:max_count] ? @parameters[:max_count] : 10
    @posts_read = GeographKdTreeHelper.get_nearby_locations CloudTm::PostLandmark, lat, lon, max_count, max_dist
    @posts_read = @posts_read.map{ |l| l.post }
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :posts_read => []
    }
    @posts_read.each do |pread|
      p.data[:posts_read] << {
        :id => pread.getExternalId,
        :latitude => pread.location.latitude.to_s,
        :longitude => pread.location.longitude.to_s
      }
    end

    Madmass.current_perception << p
  end

end
