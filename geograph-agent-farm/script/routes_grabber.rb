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

@source_path = ARGV[0]
@destination_path = ARGV[1]
@limit = ARGV[2].to_i || 100

if @source_path.nil? or @destination_path.nil?
	puts "You must pass 2 params: a source path and a destination path!"
	exit(1)
end

unless File.exists?(@source_path)
	puts "Cannot find source path: #{@source_path}!"
	exit(1)
end

puts "Starting grabbing with source path: #{@source_path}, destination path: #{@destination_path} and limit: #{@limit}"

require 'nokogiri'
require 'fileutils'

FileUtils.mkdir_p(@destination_path)
xsd_path = File.join(File.dirname(__FILE__), 'gpx.xsd')
gpx_xsd = Nokogiri::XML::Schema(File.read(xsd_path))

count = 0
Dir.glob(File.join(@source_path, '*.gpx')).each do |gpx_path|
	begin
		gpx_file = File.open(gpx_path)
	  gpx_doc = Nokogiri::XML(gpx_file)
	  
	  if gpx_xsd.validate(gpx_doc).empty?
	    puts "#{gpx_path} is valid."
	    FileUtils.cp(gpx_path, @destination_path)
	    count += 1
	  else
	  	puts "#{gpx_path} is not valid."
	  end
	  if count == @limit
	  	puts "Finished: grabbed #{count} gpx routes."
	  	break
	  end
	rescue Exception => ex
		puts ex.message
	ensure
		gpx_file.close
	end
end
