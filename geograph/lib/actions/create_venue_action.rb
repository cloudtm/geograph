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


# This file is the implementation of the  PostAction.
# The implementation must comply with the action definition pattern
# that is briefly described in the Madmass::Action::Action class.


class Actions::CreateVenueAction < Madmass::Action::Action
  action_params :latitude, :longitude, :name, :data, :user


  # the action effects.
  def execute
    CloudTm::DomainRootCache.readonly_action = false
    @venue = CloudTm::Venue.create(
      :locality_key => CloudTm::VenueLandmark.locality_key,
      :locality_value => CloudTm::VenueLandmark.locality_value(@parameters[:latitude], @parameters[:longitude]),
      :name => @parameters[:name],
    )
    @venue.location = CloudTm::Location.create(
      :latitude => BigDecimal.new(@parameters[:latitude]),
      :longitude => BigDecimal.new(@parameters[:longitude]),
      :locality_key => CloudTm::VenueLandmark.locality_key,
      :locality_value => CloudTm::VenueLandmark.locality_value(@parameters[:latitude], @parameters[:longitude]),
      :type => 'Venue',
      :body => "This is venue '#{@parameters[:name]}'<br>"
    )
    @agent.ownedVenues << @venue
    CloudTm::VenueLandmark.add_location(@venue.location)
    Madmass.logger.debug "==[#{self}] adding a location to the kdtree of the landmark"
    Madmass.logger.debug "==[#{self}] the landmark is #{@venue.location.venueLandmark}, cell = #{@venue.location.venueLandmark.x},#{@venue.location.venueLandmark.y}"
    kdt = GeographKdTree.new @venue.location.venueLandmark
    kdt << @venue.location
    Madmass.logger.debug "==[#{self}] successfully added the location to the kdtree of the landmark"
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :geo_agent => @agent.id,
      :location => {
        :id => @venue.id,
        :latitude => @venue.location.latitude.to_s,
        :longitude => @venue.location.longitude.to_s,
        :name => @venue.name,
        :data => {:body => @venue.location.body,
                  :type => @venue.location.type
        }
      }
    }

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

