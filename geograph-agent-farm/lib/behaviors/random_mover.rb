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

# Selects at random a GPX route, and executes it from the beginning to the end.
require "#{Rails.root}/lib/actions_for_behaviors"

module Behaviors
  class RandomMover < Madmass::AgentFarm::Agent::Behavior
    include ActionsForBehaviors

    def initialize
      @current_route = nil
      @position_in_route = 0
      @current_pos = nil
      @behavior_step = 0
      @was_running = false
    end

    def behavior_progress
      if @agent.status == 'running'
        if not @was_running
          @behavior_step = 0
        else
          @behavior_step += 1
        end 
        @was_running = true
      elsif @agent.status == 'stopped'
        @was_running = false
      end 
    end

    # Select a Random route
    #def choose!

   #   #raise MadMass::Errors::CatastrophicError.new("Positions in route missing") if (@current_route.include?(nil))
   # end

    def get_additional_opts
      choose!
      lat = @current_route[0][:latitude]
      lon = @current_route[0][:longitude]
      {
        :locality_hint => locality_value(lat, lon)
      }
    end

    # Select a Random route
    def choose!
#t = Time.now
      begin
        filter_type = self.opts[:track_filter_type]
        filter_value = self.opts[:track_filter_value]
        raise 'No track filter provided' if filter_type.blank? or filter_value.blank?
        servurl = URI::escape("http://cloudtm.ist.utl.pt:3000/tracks/get?#{filter_type}=#{filter_value}")
        Madmass.logger.debug "[#{self}] requesting track with [#{servurl}]"
        response = HTTParty.get(servurl)
        response = JSON.parse(response.body)
        response['content'] = JSON.parse(response['content'])
        @current_route = []
        Madmass.logger.debug "[#{self}] received a track with #{response['content'].size} positions"
        response['content'].each do |c|
          @current_route << { :latitude => c[0], :longitude => c[1] }
        end
        @position_in_route = 0
      rescue => e
        Madmass.logger.debug "[#{self}] cannot use the track provider, (exception #{e}: #{e.message}), falling back to old route loading"
        routes = CloudTm::Route.all
        if routes.any?
          random_route_pos = rand(routes.size - 1)
          routes.each_with_index do |route, index|
            if(index == random_route_pos)
              @current_route = extract_route(route)
              @position_in_route = 0
              raise MadMass::Errors::CatastrophicError.new("Positions in route missing") if (@current_route.include?(nil))
              break
            end
          end
        else
          raise Madmass::Errors::CatastrophicError.new "No GPX routes available!"
        end
      end
#Madmass.logger.error "[CHOOSE] #{(Time.now - t)}s"
    end

    def defined?
      return @current_route != nil
    end

    #Select the next action that moves from
    def next_action
      if @current_route
        action = save_user_pos_action(@current_route[@position_in_route])
#        Madmass.logger.debug "==[#{self}] saving my pos: #{@position_in_route} of #{@current_route.size}"
      else
#        Madmass.logger.debug "==[#{self}] restarting another route"
      end 
#
#      action = move_params(@current_route[@position_in_route])
#      if (@position_in_route < @current_route.size - 1)
#        @position_in_route += 1
#      else
#        @current_route = nil
#      end
      return action
    end

    def last_wish
      destroy_agent_params
    end


    private

    def advance_pos
      if @current_route
        next_pos = @current_route[@position_in_route]
        Madmass.logger.debug "==[#{self}] currently moving at pos #{@position_in_route + 1} of #{@current_route.size} (#{next_pos[:latitude].to_f.round(5)},#{next_pos[:longitude].to_f.round(5)})"
        @position_in_route += 1
        @current_route = nil if @current_route[@position_in_route].nil?
        @current_pos = next_pos
        @agent.initial_latitude ||= java.math.BigDecimal.new @current_pos[:latitude]
        @agent.initial_longitude ||= java.math.BigDecimal.new @current_pos[:longitude]
      else
        next_pos = nil
        Madmass.logger.debug "==[#{self}] no current route"
      end
      next_pos
    end 

    def extract_route dml_route
      route = []
      #FIXME: interpolate routes
      dml_route.getPositions.each do |pos|
        route[pos.progressive] = {
          :latitude => pos.latitude.to_s,
          :longitude => pos.longitude.to_s
        }
      end
      return route;
    end

  end

end

