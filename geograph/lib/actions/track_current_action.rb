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


# This file is the implementation of the  MoveAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.

module Actions
  class TrackCurrentAction < Madmass::Action::Action
    action_params :user, :latitude, :longitude, :data
    #action_states :none
    #next_state :none

    # [MANDATORY] Override this method in your action to define
    # the action effects.
    def execute
      CloudTm::DomainRootCache.readonly_action = false
      # if the current track don't exists create a new one
      unless @agent.current_track
        @agent.current_track = CloudTm::Track.factory
        # add the track in the agent tracks collection
        @agent.addTracks(@agent.current_track)
      end

      # create the agent position (aka geo object)
      @location = CloudTm::Location.create(
        :latitude => BigDecimal.new(@parameters[:latitude]),
        :longitude => BigDecimal.new(@parameters[:longitude]),
        :locality_key => CloudTm::TrackableLandmark.locality_key,
        :locality_value => CloudTm::TrackableLandmark.locality_value(@parameters[:latitude], @parameters[:longitude]),
      )

      @location.trackableLandmark = CloudTm::TrackableLandmark.get_landmark(@location)

      # remove the previous position from the landmark
      previous_position = @agent.current_position
      if previous_position
        landmark = previous_position.trackableLandmark
        landmark.removeTrackableLocations(previous_position)
      end

      # set the agent current position
      @location.type = 'Mover'
      @location.body = "Mover with position\n <#{@parameters[:latitude].to_f.round(5)}, #{@parameters[:longitude].to_f.round(5)}>"
      @agent.current_position = @location

      # track the new position
      # TODO: add a progressive counter
      @location.type = 'Track'
      @location.body = "Track\n <#{@parameters[:latitude].to_f.round(5)}, #{@parameters[:longitude].to_f.round(5)}>"
      @agent.current_track.addLocations(@location)

      # attach the new position to the landmark
      CloudTm::TrackableLandmark.add_location(@location)
    end

    # the perception content.
    def build_result
      p = Madmass::Perception::Percept.new(self)
      
      p.data = {
        :geo_agent => @agent.id,
        :location => {
          :id => @location.id,
          :latitude => @location.latitude.to_s,
          :longitude => @location.longitude.to_s,
          :data => {
            :body => @location.body,
            :type => @location.type
          }
        }
      }

      Madmass.current_perception << p
    end

    def applicable?
      @agent = CloudTm::Trackable.find_by_user(@parameters[:user][:id])
      unless @agent
        why_not_applicable.publish(
          :name => :track_current_position,
          :key => 'action.track.current_position',
          :recipients => [@parameters[:user][:id]]
        )
      end
      return why_not_applicable.empty?
    end

  end

end
