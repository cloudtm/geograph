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

#Capistrano support
require 'torquebox-capistrano-support'
require 'bundler/capistrano'

# source code
set :application,       "geograph-agent-farm"
set :repository,        "https://github.com/algorithmica/geograph-agent-farm.git"
set :branch,            "master"
set :user,              "torquebox"
set :scm,               :git
set :scm_verbose,       true
set :use_sudo,          false
#set :test_server,       "vm-178.uc.futuregrid.org"
# Production server

set :deploy_to,         "/opt/apps/#{application}"
set :torquebox_home,    "/opt/torquebox/current"
set :jboss_init_script, "/etc/init.d/jboss-as-standalone"
#set :app_environment,   "RAILS_ENV: production" DOES NOT WORK!!!
set :app_context,       "/farm"
set :app_ruby_version,  '1.9'


#Added by vittorio
#default_run_options[:pty] = true
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = "publickey"
ssh_options[:keys] = %w(~/.ssh/id_rsa)
set :deploy_via, :remote_cache

ssh_options[:forward_agent] = false

#Precompile asset pipeline
load 'deploy/assets'


role :web, "10.100.0.100"
role :app, "10.100.0.100"
role :db,  "10.100.0.100", :primary => true
