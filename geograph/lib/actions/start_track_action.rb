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
  class StartTrackAction < Madmass::Action::Action
    action_params :user, :latitude, :longitude, :data

    def execute
      CloudTm::DomainRootCache.readonly_action = false
      @agent.current_track = nil
    end

    def build_result
      p = Madmass::Perception::Percept.new(self)
      
      p.data = {
        :geo_agent => @agent.id,
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
