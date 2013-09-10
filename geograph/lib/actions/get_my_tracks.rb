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

require 'haversine_distance.rb'

class Actions::GetMyTracksAction < Madmass::Action::Action
  action_params :latitude, :longitude, :user, :max_dist, :max_count

  def initialize params
    super
    @channels << :all
  end

  # the action effects.
  def execute
    CloudTm::DomainRootCache.readonly_action = true
    Madmass.logger.debug "==[#{self}] ---"
    # nothing to do for this action, we already have all
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :my_tracks => []
    }
    @agent.tracks.each do |track|
      track_json = []
      track.locations.each do |location|
        track_json << { :latitude => location.latitude, :longitude => location.longitude }
      end
      p.data[:my_tracks] << track_json
    end

    Madmass.current_perception << p
  end

  def applicable?
    @agent = CloudTm::Trackable.find_by_user(@parameters[:user][:id])
    unless @agent
      why_not_applicable.publish(
        :name => :post_blog,
        :key => 'action.post.blog',
        :recipients => [@parameters[:user][:id]]
      )
    end
    return why_not_applicable.empty?
  end

end
