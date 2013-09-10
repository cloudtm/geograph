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
  class RegisterAgentAction < Madmass::Action::Action
    action_params :user, :data


    # the action effects.
    def execute
      CloudTm::DomainRootCache.readonly_action = false
      Madmass.logger.debug("Executing register agent action with parameters #{@parameters.inspect}")
      @agent = CloudTm::Agent.find_by_user(@parameters[:user][:id])
      unless @agent
Madmass.logger.error "GEOGRAPH REGISTERING AGENT with this locality value #{@parameters[:data][:opts][:locality_hint]}"
        Madmass.logger.debug("User #{@parameters[:user][:id]} not found, creating new agent")
        @agent = CloudTm::Agent.factory( 
          :user => @parameters[:user][:id], 
          :type => @parameters[:data][:type],
          :locality_key => Java::EuCloudtm::Constants::GROUP_ID,
          :locality_value => @parameters[:data][:opts][:locality_hint] || nil
        )
      end
    end

    # [MANDATORY] Override this method in your action to define
    # the perception content.
    def build_result
      p = Madmass::Perception::Percept.new(self)
      p.data = {:agent_id => @agent.id}
      Madmass.current_perception << p
    end

  end

end
