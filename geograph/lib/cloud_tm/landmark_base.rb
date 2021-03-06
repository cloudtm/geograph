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
require "#{Rails.root}/lib/geograph_options"

module CloudTm
  module LandmarkBase
    def self.included(base)
      base.send(:include, CloudTm::Model)
      base.extend(ClassMethods)
    end    

    # Grid cell size in meters
    CELL_SIZE = BigDecimal.new(GeographOptions[:landmark_grid][:cell_size])  # 5000
    # The latitude and longitude size change
    # 0°  110.574 km  111.320 km
    # 15° 110.649 km  107.551 km
    # 30° 110.852 km  96.486 km
    # 45° 111.132 km  78.847 km
    # 60° 111.412 km  55.800 km
    # 75° 111.618 km  28.902 km
    # 90° 111.694 km  0.000 km
    LONGITUDE_SIZE = BigDecimal.new("111320")   # longitude * LONGITUDE_SIZE = meters
    LATITUDE_SIZE = BigDecimal.new("110574")    # latitude * LATITUDE_SIZE = meters

    def attributes_to_hash
      {
        :id => getExternalId,
        :latitude => latitude.to_s,
        :longitude => longitude.to_s,
        :x => x,
        :y => y,
        :cell => cell,
        :data => { :type => type, :body => body }
      }
    end

    def destroy
      domain_root.removeLandmarks(self)
    end

    module ClassMethods

      def locality_key
        Java::EuCloudtm::Constants::GROUP_ID
        #'landmark'
      end

      def locality_value(latitude, longitude)
        cell = coordinates_to_cell(BigDecimal.new(latitude), BigDecimal.new(longitude))
        cell_index(cell)
      end

      # Returns the landmark associated to the cell. 
      # The cell is an hash like: { x: 23 , y: 12 }
      def find_by_coordinates(latitude, longitude)
        cell = coordinates_to_cell(latitude, longitude)
        find_by_cell(cell)
      end

      # Returns the landmark associated to the cell. 
      # The cell is an hash like: {x: 23 , y: 12]
      def find_by_cell(cell)
        if self == CloudTm::PostLandmark
          if GeographOptions[:l2_cache][:enabled]
            if CloudTm::DomainRootCache.readonly_action
              domain_root.getPostLandmarksByCellCached(false, cell_index(cell)) || domain_root.getPostLandmarksByCellCached(true, cell_index(cell))
            else
              domain_root.getPostLandmarksByCellCached(true, cell_index(cell))
            end
          else
            domain_root.getPostLandmarksByCell(cell_index(cell))
          end
        elsif self == CloudTm::VenueLandmark
          if GeographOptions[:l2_cache][:enabled]
            if CloudTm::DomainRootCache.readonly_action
              domain_root.getVenueLandmarksByCellCached(false, cell_index(cell)) || domain_root.getVenueLandmarksByCellCached(true, cell_index(cell))
            else
              domain_root.getVenueLandmarksByCellCached(true, cell_index(cell))
            end
          else
            domain_root.getVenueLandmarksByCell(cell_index(cell))
          end
        elsif self == CloudTm::TrackableLandmark
          if GeographOptions[:l2_cache][:enabled]
            if CloudTm::DomainRootCache.readonly_action
              domain_root.getTrackableLandmarksByCellCached(false, cell_index(cell)) || domain_root.getTrackableLandmarksByCellCached(true, cell_index(cell))
            else
              domain_root.getTrackableLandmarksByCellCached(true, cell_index(cell))
            end
          else
            domain_root.getTrackableLandmarksByCell(cell_index(cell))
          end
        end
      end

      def cell_index(cell)
        ("%+011d" % cell[:x]) + ',' + ("%+011d" % cell[:y])
      end

      def coordinates_to_cell(latitude, longitude)
        {
          x: (normalize_longitude(longitude) * LONGITUDE_SIZE / CELL_SIZE).to_f.floor,
          y: (normalize_latitude(latitude) * LATITUDE_SIZE / CELL_SIZE).to_f.floor
        }
      end

      def normalize_longitude(longitude)
        ((longitude + BigDecimal.new("180")) % BigDecimal.new("360") ) - BigDecimal.new("180")
      end

      def normalize_latitude(latitude)
        ( ( latitude + BigDecimal.new("90")) % BigDecimal.new("180") ) - BigDecimal.new("90")
      end

      # The longitude of the cell. Is the cell center longitude.
      def longitude(cell)
        ( ( BigDecimal.new(cell[:x]) + BigDecimal.new("0.5") )  * CELL_SIZE) / LONGITUDE_SIZE
      end

      # The latitude of the cell. Is the cell center latitude.
      def latitude(cell)
        ( ( BigDecimal.new(cell[:y]) + BigDecimal.new("0.5") ) * CELL_SIZE) / LATITUDE_SIZE
      end

      def get_landmark(location)
        cell = coordinates_to_cell(location.latitude, location.longitude)
        landmark = find_by_cell(cell)
        if !landmark && !CloudTm::DomainRootCache.readonly_action
#        unless landmark || CloudTm::DomainRootCache.readonly_action
          cell_index = cell_index(cell)
          lat = latitude(cell)
          lon = longitude(cell)
          landmark = create(
            type: 'Landmark', 
            body: "cell: #{cell_index} - lat: #{lat} - lon: #{lon}",
            x: cell[:x], 
            y: cell[:y],
            cell: cell_index,
            latitude: lat,
            longitude: lon,
            locality_key: locality_key,
            locality_value: cell_index,
            lkey: locality_key,
            lval: cell_index
          )
        end
        landmark
      end

      def add_location location, landmark = nil
        if self == CloudTm::PostLandmark
          location.postLandmark = landmark || get_landmark(location)
        elsif self == CloudTm::VenueLandmark
          location.venueLandmark = landmark || get_landmark(location)
        elsif self == CloudTm::TrackableLandmark
          location.trackableLandmark = landmark || get_landmark(location)
        end
      end

      def create attrs = {}, &block
        instance = super
        if self == CloudTm::PostLandmark
          domain_root.addPostLandmarks instance
          instance
        elsif self == CloudTm::VenueLandmark
          domain_root.addVenueLandmarks instance
          instance
        elsif self == CloudTm::TrackableLandmark
          domain_root.addTrackableLandmarks instance
          instance
        else
          nil
        end
      end

      def all
        if self == CloudTm::PostLandmark
          domain_root.getPostLandmarks.to_a 
        elsif self == CloudTm::VenueLandmark
          domain_root.getVenueLandmarks.to_a
        elsif self == CloudTm::TrackableLandmark
          domain_root.getTrackableLandmarks.to_a
        end
      end

    end
  end
end 
