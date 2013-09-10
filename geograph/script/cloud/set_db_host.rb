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

# This script given a host name of the database master node and generates an appropriate database.yml file.
require 'yaml'

HOST_PLACEHOLDER = "{HOST}"
DBNAME_PLACEHOLDER = '{DBNAME}'

# app name (it must corresponds to the source code folder that contain the project)
#appname = "geograph"
appname = ARGV[0]
dbname = ARGV[1]

# load the db host from the cluster_nodes.yml generated during nimbus 1-ipandhost phase
conf_file = "cluster_nodes.yml"
hosts_file_path = File.join("/tmp", conf_file)
hosts = {}
File.open(hosts_file_path, 'r') do |file|
  hosts = YAML.load(file.read)
end
host = hosts[:db_nodes].first

puts "start setting db host with arguments app: #{appname} db ip: #{host} ..."

# this is the absolute path of geograph source code inside the cloud nodes
source_root = "/opt/apps/#{appname}/current"

# path to the database.yml configuration file
database_conf = File.join("#{source_root}", 'config', 'database.yml')

current_path = File.dirname(File.expand_path(__FILE__))
# path to the database.yml template file
database_conf_template = File.join("#{current_path}", 'templates', 'database.yml.template')


# open the template file, replace the HOST_PLACEHOLDER with the host argument and override the original conf file
File.open(database_conf_template, 'r') do |template|
  db_conf = template.read.gsub(HOST_PLACEHOLDER, host)
  db_conf.gsub!(DBNAME_PLACEHOLDER, dbname)
  #puts "changing database configuration with: \n #{db_conf}"
  File.open(database_conf, 'w') do |original|
    original.write db_conf
  end
end

puts "db host set!"
