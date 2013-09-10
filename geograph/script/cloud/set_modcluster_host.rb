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

# This script given a host name of the mod cluster node node and generates an appropriate httpd.conf file.
host = %x(hostname).gsub("\n", '')
puts "start setting mod cluster host with arguments #{host} ..."

HOST_PLACEHOLDER = "{HOST}"

# this is the absolute path of geograph source code inside the cloud nodes
source_root = "/opt/jboss/httpd/httpd/conf"
current_path = File.dirname(File.expand_path(__FILE__))

# path to the httpd.conf configuration file to replace
httpd_conf = File.join("#{source_root}", 'httpd.conf')

# path to the httpd.conf template file
httpd_conf_template = File.join("#{current_path}", 'templates', 'httpd.conf.template')


# open the template file, replace the HOST_PLACEHOLDER with the host argument and override the original conf file
File.open(httpd_conf_template, 'r') do |template|
  httpd_conf_data = template.read.gsub(HOST_PLACEHOLDER, host)
  File.open(httpd_conf, 'w') do |original|
    original.write httpd_conf_data
  end
end

puts "mod cluster host set!"
