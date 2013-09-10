###############################################################################
################################################################################
##
## This file is part of GeoGraph.
##
## Copyright (c) 2012 Algorithmica Srl
##
## GeoGraph is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## GeoGraph is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
##
## Contact us via email at info@algorithmica.it or at
##
## Algorithmica Srl
## Largo Alfredo Oriani 12
## 00152 Rome, Italy
##
################################################################################
################################################################################

require "#{Rails.root}/lib/kd_tree"
require "#{Rails.root}/lib/distance"
require "#{Rails.root}/lib/geograph_options"

module GeographKdMethods
  def [] i
    if i == 0
      return self.latitude.to_f
    elsif i == 1
      return self.longitude.to_f
    else
      return nil
    end
  end
  def dist2 other
    #Distance.calculate self.latitude, self.longitude, other[0], other[1]
    (self.latitude.to_f - other[0].to_f) ** 2 + (self.longitude.to_f - other[1].to_f) ** 2
  end
end

class CloudTm::Location
#  include CloudTm::Model
  include GeographKdMethods
end

class CloudTm::KdNode
  include CloudTm::Model
  attr_accessor :dist2sample
#  def initialize x
#    super x
#    @dist2sample = 0.0
#  end
end

class KdNodeFactory
  def initialize root_landmark
    @root_landmark = root_landmark
  end
  def factory
    n = CloudTm::KdNode.create({
      :locality_key => @root_landmark.lkey,
      :locality_value => @root_landmark.lval
    })
    n.dist2sample = 0.0
    n
  end
end

class GeographKdTree < KdTree
  def initialize root_landmark
    factory = KdNodeFactory.new root_landmark
    super factory
    if not root_landmark.kd_root
      kdr = factory.factory
      lochints = Java::EuCloudtm::LocalityHints.new
      lochints.addHint(root_landmark.lkey, root_landmark.lval)
      landmark_location = CloudTm::Location.new lochints
      landmark_location.latitude = root_landmark.latitude
      landmark_location.longitude = root_landmark.longitude

      kdr.sample = landmark_location
      kdr.enabled = false
      kdr.split_dim = 0
      root_landmark.kd_root = kdr
    end
    self.set_root root_landmark.kd_root
  end
end

class GeographKdTreeHelper
  def self.get_nearby_locations landmark_class, lat, lon, max_count, max_dist
    t1 = Time.now
    nearby_locs = []
    max_dist = GeographOptions[:nearest_neighbours_search][:radius]
    min_latitude  = lat.to_f - max_dist / landmark_class::LATITUDE_SIZE.to_f
    max_latitude  = lat.to_f + max_dist / landmark_class::LATITUDE_SIZE.to_f
    min_longitude = lon.to_f - max_dist / landmark_class::LONGITUDE_SIZE.to_f
    max_longitude = lon.to_f + max_dist / landmark_class::LONGITUDE_SIZE.to_f
    #Madmass.logger.debug "==[#{self}] Location: #{lat},#{lon}, min_loc: #{min_latitude},#{min_longitude}, max_loc: #{max_latitude},#{max_longitude}"
    min_cell = landmark_class.coordinates_to_cell(BigDecimal.new(min_latitude), BigDecimal.new(min_longitude))
    max_cell = landmark_class.coordinates_to_cell(BigDecimal.new(max_latitude), BigDecimal.new(max_longitude))
    #Madmass.logger.debug "==[#{self}] min_cell: #{min_cell.inspect}, max_cell: #{max_cell.inspect}"
    (min_cell[:x]..max_cell[:x]).each do |x|
      (min_cell[:y]..max_cell[:y]).each do |y|
        nbl = get_nearby_locations_by_xy landmark_class, x, y, lat, lon, max_count, max_dist
        nearby_locs = nearby_locs + nbl 
      end
    end
    nearby_locs.sort_by! { |obj| obj.dist2sample } # { |a, b| a.dist2sample <=> b.dist2sample }
    #Madmass.logger.debug "==[#{self}] Found #{nearby_locs.size} locations, cropped to #{[max_count,nearby_locs.size].min}"
    nearby_locs = nearby_locs[0..max_count-1]
    ret = nearby_locs.map { |l| l.sample }
    #Madmass.logger.error "KD-TREE TOTAL TIME: #{(Time.now - t1).to_f}"
    ret
  end

  def self.get_nearby_locations_by_xy landmark_class, landmark_x, landmark_y, lat, lon, max_count, max_dist
    landmark = landmark_class.find_by_cell({ x: landmark_x, y: landmark_y })
    #if not landmark
    #  Madmass.logger.debug "==[#{self}] No landmark for cell #{landmark_x},#{landmark_y}"
    #end
    get_nearby_locations_by_landmark landmark_class, landmark, lat, lon, max_count, max_dist
  end

  def self.get_nearby_locations_by_landmark landmark_class, landmark, lat, lon, max_count, max_dist
    nearby_locs = []
    if landmark
      kdt = GeographKdTree.new landmark
      #Madmass.logger.error "KD-TREE before rebalancing #{kdt.to_s}"
      #kdt.rebalance
      #landmark.kd_root = kdt.get_root
      #Madmass.logger.error "KD-TREE after rebalancing #{kdt.to_s}"
      t1 = Time.new
      #Madmass.logger.debug "==[#{self}] The KD-Tree root is #{kdt.get_root.inspect}"
      nearby_locs = kdt.knn([lat, lon], max_count, [ :return_nodes ])
      #Madmass.logger.debug "==[#{self}] Found #{nearby_locs.size} posts with KD-Tree"
      #Madmass.logger.error "KD-TREE SINGLE: #{(Time.new - t1).to_f}"
    #else
    #  Madmass.logger.debug "==[#{self}] No landmark here: #{lat},#{lon}"
    end
    nearby_locs
  end
end

