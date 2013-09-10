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

require 'yaml'

key = ARGV[0].to_sym
host = ARGV[1]

puts "adding node for #{key}: #{host} ..."

conf_file = "cluster_nodes.yml"
conf_path = File.join("/tmp", conf_file)

hosts = {}

if File.exists?(conf_path)
  File.open(conf_path, 'r') do |file|
    hosts = YAML.load(file.read)
  end
end

hosts[key] ||= []
hosts[key] << host
hosts_dump = YAML.dump hosts
File.open(conf_path, 'w') do |file|
  file.write hosts_dump
end

puts "node added."
