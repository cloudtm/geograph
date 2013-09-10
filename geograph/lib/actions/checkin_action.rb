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


class Actions::CheckinAction < Madmass::Action::Action
  action_params :venue_id, :latitude, :longitude, :user

  def initialize params
    super
  end

  def execute
    CloudTm::DomainRootCache.readonly_action = false
    lat = BigDecimal.new(@parameters[:latitude])
    lon  = BigDecimal.new(@parameters[:longitude])
    landmark = CloudTm::VenueLandmark.find_by_coordinates(lat, lon)
    @venue = CloudTm::Venue.find_by_id(@parameters[:venue_id])
    if @venue
      if @agent.current_venue
        Madmass.logger.debug "==[#{self}] agent was at venue #{@agent.current_venue}"
        @agent.current_venue.remove_agents(@agent)
      end
      @agent.current_venue = @venue
      @venue.visitor_agents << @agent
      Madmass.logger.debug "==[#{self}] now agent is at venue #{@agent.current_venue}"
    else
      Madmass.logger.error "==[#{self}] cannot find venue with id #{@parameters[:venue_id]}"
    end
  end

  def build_result
    p = Madmass::Perception::Percept.new(self)
   
    if @venue
      p.data = {
        :venue_id => @venue.id
      }
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
