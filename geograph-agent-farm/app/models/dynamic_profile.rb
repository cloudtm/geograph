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

class DynamicProfile < ActiveRecord::Base
  validates_uniqueness_of :name
  attr_accessible :name, :user_id, :iterations, :current_iteration
  belongs_to :user
  belongs_to :benchmark_schedule
  acts_as_list :scope => :benchmark_schedule
  has_many :static_profiles, :order => "position", :dependent => :destroy

  class << self
	  def max_position benchmark_schedule_id
	  	joins(:benchmark_schedule).where("benchmark_schedules.id = ?", benchmark_schedule_id).maximum(:position) || 0
	  end
	end
end
