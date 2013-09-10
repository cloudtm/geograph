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

require "#{Rails.root}/lib/geograph_kd_tree"

class Actions::PostAction < Madmass::Action::Action
  action_params :latitude, :longitude, :data, :user, :batch_count, :batch_radius

  LIPSUM = <<EOL
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean molestie tincidunt magna at suscipit. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut luctus ultrices lobortis. Donec aliquet pharetra pretium. Ut aliquet a sem in egestas. Proin nec nulla pulvinar, pulvinar nunc eu, suscipit ante. Ut eget cursus neque. Aliquam placerat, enim a suscipit vehicula, velit nibh fringilla leo, et ultricies odio nulla ac mauris. Maecenas tristique viverra luctus. Fusce vitae nunc posuere, mattis lacus pretium, varius odio. Donec a est ut sem aliquet fringilla et id purus.

Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Suspendisse tortor neque, commodo sodales tempus eget, laoreet nec ligula. Aenean consequat massa ante, sed pulvinar tellus faucibus ac. Etiam placerat dolor ac erat accumsan interdum. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec dui cras amet.
EOL

  # the action effects.
  def execute
    CloudTm::DomainRootCache.readonly_action = false
    type = @parameters[:type]
    count = @parameters[:batch_count] || 1
    radius = @parameters[:batch_radius] || 0
    Madmass.logger.error "Agent #{@agent.id} is adding #{count} posts in a #{radius} m radius"
    landmarks_cache = { }
    count.times do
      lat = @parameters[:latitude].to_f + (Math.cos(rand * Math::PI) * radius) / CloudTm::PostLandmark::LATITUDE_SIZE.to_f
      lon = @parameters[:longitude].to_f + (Math.sin(rand * Math::PI) * radius) / CloudTm::PostLandmark::LONGITUDE_SIZE.to_f
      locality_key = CloudTm::PostLandmark.locality_key
      locality_value = CloudTm::PostLandmark.locality_value(lat, lon)
      @geo_post = CloudTm::Post.create(
        :locality_key => locality_key,
        :locality_value => locality_value,
        :text => ((not type or type == 'text') ? LIPSUM :
          type == 'image' ? '#' * 7 * 100 * 1024 :
          type == 'video' ? '#' * 3 * 1024 * 1024 : '')
      )
      @geo_post.location = CloudTm::Location.create(
        :body => "This is the text of the post: blah blah blah (type: #{type})<br>", #@parameters[:data][:body],
        :type => 'Post',  #@parameters[:data][:type],
        :latitude => BigDecimal.new(lat),
        :longitude => BigDecimal.new(lon),
        :locality_key => locality_key,
        :locality_value => locality_value
      )
      @agent.addPosts(@geo_post)
      if not landmarks_cache[locality_value]
        landmark = CloudTm::PostLandmark.get_landmark(@geo_post.location)
        landmarks_cache[locality_value] = landmark
      else
        landmark = landmarks_cache[locality_value]
      end
      CloudTm::PostLandmark.add_location(@geo_post.location, landmark)
      Madmass.logger.debug "==[#{self}] added #{@geo_post.location.inspect}"
      Madmass.logger.debug "==[#{self}] adding a location to the kdtree of the landmark"
      Madmass.logger.debug "==[#{self}] the landmark is #{@geo_post.location.postLandmark}, cell = #{@geo_post.location.postLandmark.x},#{@geo_post.location.postLandmark.y}"
      kdt = GeographKdTree.new @geo_post.location.postLandmark
      kdt << @geo_post.location
      Madmass.logger.debug "==[#{self}] successfully added the location to the kdtree of the landmark"
    end
  end

  # the perception content.
  def build_result
    p = Madmass::Perception::Percept.new(self)
    p.data = {
      :geo_agent => @agent.id,
      :location => {
        :id => @geo_post.id,
        :latitude => @geo_post.location.latitude.to_s,
        :longitude => @geo_post.location.longitude.to_s,
        :data => {:body => @geo_post.location.body,
                  :type => @geo_post.location.type
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

