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
  class SaveUserPosAction < Madmass::Action::Action
    action_params :user, :latitude, :longitude, :data

    def execute
      CloudTm::DomainRootCache.readonly_action = false
      if not @agent.current_position
        @location = CloudTm::Location.create(
          :latitude => BigDecimal.new(@parameters[:latitude]),
          :longitude => BigDecimal.new(@parameters[:longitude]),
          :locality_key => CloudTm::TrackableLandmark.locality_key,
          :locality_value => CloudTm::TrackableLandmark.locality_value(@parameters[:latitude], @parameters[:longitude]),
        )
        @location.trackableLandmark = CloudTm::TrackableLandmark.get_landmark(@location)
        @location.type = 'Mover'
        @location.body = "Mover with position\n <#{@parameters[:latitude].to_f.round(5)}, #{@parameters[:longitude].to_f.round(5)}>"

        @agent.current_position = @location
      else
        @location = @agent.current_position
        @agent.current_position.latitude = BigDecimal.new(@parameters[:latitude])
        @agent.current_position.longitude = BigDecimal.new(@parameters[:longitude])
        new_landmark = CloudTm::TrackableLandmark.get_landmark(@agent.current_position)
        if new_landmark != @agent.current_position.landmark
          @agent.current_position.trackableLandmark = new_landmark
        end
        @agent.current_position.body = "Mover with position\n <#{@parameters[:latitude].to_f.round(5)}, #{@parameters[:longitude].to_f.round(5)}>"
      end
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
