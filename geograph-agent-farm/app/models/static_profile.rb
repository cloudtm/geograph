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

class StaticProfile < ActiveRecord::Base
  attr_accessible :duration, :dynamic_profile_id, :position
  acts_as_list :scope => :dynamic_profile
  has_many :agent_groups, :dependent => :destroy
  belongs_to :dynamic_profile
  has_one :static_profile

  class << self
    def max_position dynamic_profile_id
      joins(:dynamic_profile).where("dynamic_profiles.id = ?", dynamic_profile_id).maximum(:position) || 0
    end
  end

  def start
    Rails.logger.debug "Starting Static Profile"
    agent_groups.each do |g|
      g.deploy
    end

    agent_groups.each do |g|
      g.start
    end
  end

  def stop
    Rails.logger.debug "Stopping Static Profile"
    agent_groups.each do |g|
      g.shutdown
    end
  end
end
