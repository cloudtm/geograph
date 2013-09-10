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

module CloudTm
	class DistributedExecutor
		def initialize
			cache = FenixFramework.getConfig.getBackEnd.getInfinispanCache
			@executor = CloudTm::DefaultExecutorService.new(cache)
		end

		def execute
#			task = CloudTm::DistributedTask.new("")
#			@executor.submitEverywhere(task)#.get
      # SHOULD BE
      # (see https://github.com/pruivo/infinispan/blob/cloudtm_v3/core/src/main/java/org/infinispan/distexec/DistributedExecutorService.java#L102)
      CloudTm::PostLandmark.all.each do |landmark|
        puts "Calling PostLandmark, #{landmark.getCell()}"
        task = CloudTm::DistributedTask.new("PostLandmark", landmark.getCell())
        keys = FenixFramework.getStorageKeys(landmark);
        @executor.submit(task, keys);
      end
      CloudTm::VenueLandmark.all.each do |landmark|
        puts "Calling VenueLandmark, #{landmark.getCell()}"
        task = CloudTm::DistributedTask.new("VenueLandmark", landmark.getCell())
        keys = FenixFramework.getStorageKeys(landmark);
        @executor.submit(task, keys);
      end
      CloudTm::TrackableLandmark.all.each do |landmark|
        puts "Calling TrackableLandmark, #{landmark.getCell()}"
        task = CloudTm::DistributedTask.new("TrackableLandmark", landmark.getCell())
        keys = FenixFramework.getStorageKeys(landmark);
        @executor.submit(task, keys);
      end
		end

	end
end
