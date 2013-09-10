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

class HomeController < ApplicationController
  before_filter :authenticate_agent
  include Madmass::Transaction::TxMonitor
  around_filter :transact
  respond_to :html, :js
  
  def index
    @locations = CloudTm::Location.all.to_dml_json
  end

  def map
    locations_in_cache = CloudTm::Location.all
    @locations = locations_in_cache.to_dml_json
    @edges = locations_in_cache.map(&:edges_for_percept).flatten.reject{|x| x == nil}.to_json #FIXME
  end

  def stats
  end

  def stats_ajax
    landmarks = CloudTm::PostLandmark.all + CloudTm::VenueLandmark.all + CloudTm::TrackableLandmark.all
    @stats = { }
    landmarks.each do |l|
      if l.cell and l.stats
        if not @stats[l.cell]
          @stats[l.cell] = { :landmark => l.cell, :posts => 0, :postLikes => 0, :postComments => 0, :venues => 0, :venueLikes => 0, :venueComments => 0,
                             :agentsInVenues => 0, :trackables => 0 }
        end
        @stats[l.cell][:posts] += l.stats.posts if l.stats.posts
        @stats[l.cell][:postLikes] += l.stats.postLikes if l.stats.postLikes
        @stats[l.cell][:postComments] += l.stats.postComments if l.stats.postComments
        @stats[l.cell][:venues] += l.stats.venues if l.stats.venues
        @stats[l.cell][:venueLikes] += l.stats.venueLikes if l.stats.venueLikes
        @stats[l.cell][:venueComments] += l.stats.venueComments if l.stats.venueComments
        @stats[l.cell][:agentsInVenues] += l.stats.agentsInVenues if l.stats.agentsInVenues
        @stats[l.cell][:trackables] += l.stats.trackables if l.stats.trackables
      end
    end
    @stats = @stats.map{ |k, v| v }.sort { |a, b| a[:landmark] <=> b[:landmark] }
  end

  def landmarks_map
    @landmarks = CloudTm::PostLandmark.all + CloudTm::VenueLandmark.all + CloudTm::TrackableLandmark.all
    locations = []
    edges = []
    CloudTm::TrackableLandmark.all.each do |land| 
      land.trackableLocations.each do |loc| 
        locations << loc 
        edges << {
          :from => { :id => land.externalId, :latitude => land.latitude.to_s, :longitude => land.longitude.to_s }, 
          :to =>   { :id => loc.externalId, :latitude => loc.latitude.to_s, :longitude => loc.longitude.to_s }
        }
      end
    end

    (CloudTm::PostLandmark.all + CloudTm::VenueLandmark.all).each do |land| 
      tree = GeographKdTree.new land
      tree.all[0..2].each do |loc| 
        locations << loc
        edges << {
          :from => { :id => land.externalId, :latitude => land.latitude.to_s, :longitude => land.longitude.to_s }, 
          :to =>   { :id => loc.externalId, :latitude => loc.latitude.to_s, :longitude => loc.longitude.to_s }
        }
      end
    end

    # get all agents tracks
    agents = CloudTm::Trackable.all
    agents.each do |agent|
      next if(agent.class != CloudTm::Trackable)
      agent.tracks.each do |track|
        track.locations.each do |location|
          if location.type == 'Track'
            locations << location 
          end
        end
      end
    end

    @locations = locations.to_dml_json
    @landmarks_objects = @landmarks.to_dml_json
    @edges = edges.to_json
  end

  private

  def transact
    tx_monitor do
      yield
    end
  end

end
