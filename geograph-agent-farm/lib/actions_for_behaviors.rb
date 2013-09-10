###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Largo Alfredo Oriani 12
# 00152 Rome, Italy
#
###############################################################################
###############################################################################
require "#{Rails.root}/lib/geograph_options"

module ActionsForBehaviors

#    REMOTE_ACTION_NAME = "madmass::action::remote"
    REMOTE_ACTION_NAME = "lard_remote"

    CELL_SIZE = GeographOptions[:landmark_grid][:cell_size]
    LONGITUDE_SIZE = 111320.0
    LATITUDE_SIZE = 110574.0

    def cell_index(cell)
      ("%+011d" % cell[:x]) + ',' + ("%+011d" % cell[:y])
    end

    def locality_value(latitude, longitude)
      if not latitude or not longitude
        nil
      else
        cell = coordinates_to_cell(latitude, longitude)
        cell_index(cell)
      end
    end

    def coordinates_to_cell(latitude, longitude)
      {
        x: (normalize_longitude(longitude) * LONGITUDE_SIZE / CELL_SIZE).to_f.floor,
        y: (normalize_latitude(latitude) * LATITUDE_SIZE / CELL_SIZE).to_f.floor
      }
    end

    def normalize_longitude(longitude)
      ((longitude.to_f + 180.0) % 360.0) - 180.0
    end

    def normalize_latitude(latitude)
      ((latitude.to_f + 90.0) % 180.0) - 90.0
    end

    def checkin_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      venue_id = opts[:venue_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::checkin',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :venue_id => venue_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def comment_post_action opts
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      post_id = opts[:post_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::comment_post',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :post_id => post_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def comment_venue_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      venue_id = opts[:venue_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::comment_venue',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :venue_id => venue_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def create_venue_action opts
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::create_venue',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :name => opts[:name],
          :user => { :id => @agent.id }
        }
      }
    end

    def geo_post_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::post',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :batch_count => GeographOptions[:batch_add_posts][:count] || 1,
          :batch_radius => GeographOptions[:batch_add_posts][:radius] || 0,
          :locality_hint => locality_value(lat, lon),
          :user => {:id => @agent.id}
        }
      }
    end

    def get_curr_friends_at_venue_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      venue_id = opts[:venue_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::get_curr_friends_at_venue',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :venue_id => venue_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def get_my_tracks_action opts = {}
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'get_my_tracks',
          :sync => true,
          :can_write => false,
          :locality_hint => locality_value(@current_pos[:latitude], @current_pos[:longitude]),
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

    def get_nearby_friends_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'get_nearby_friends',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

    def get_nearby_posts_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::get_nearby_posts',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :max_count => 10,
          :max_dist => 10000,
          :user => { :id => @agent.id }
        }
      }
    end

    def get_nearby_venues_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::get_nearby_venues',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :max_count => 10,
          :max_dist => 10000,
          :user => { :id => @agent.id }
        }
      }
    end

    def get_past_friends_at_venue_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      venue_id = opts[:venue_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::get_past_friends_at_venue',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :venue_id => venue_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def like_post_action opts
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      post_id = opts[:post_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::like_post',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :post_id => post_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def like_venue_action opts
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      venue_id = opts[:venue_id]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::like_venue',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :venue_id => venue_id,
          :user => { :id => @agent.id }
        }
      }
    end

    def save_user_pos_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'save_user_pos',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

    def start_track_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'start_track',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

    def track_current_action opts = {}
      if not @current_pos
        return nil
      end
      lat = @current_pos[:latitude]
      lon = @current_pos[:longitude]
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'track_current',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :user => { :id => @agent.id }
        }.merge(opts)
      }
    end

    def destroy_agent_action opts = {}
      if not @current_pos
        nil
      else
        {
          :cmd => REMOTE_ACTION_NAME,
          :data => {
            :cmd => 'destroy_agent',
            :sync => true,
            :can_write => true,
            :locality_hint => locality_value(@current_pos[:latitude], @current_pos[:longitude]),
            :user => { :id => @agent.id }
          }.merge(opts)
        }
      end
    end

    def geo_post_object opts

      lat = opts[:latitude].to_s.to_f + (0.5 - rand) * 0.05
      lon = opts[:longitude].to_s.to_f + (0.5 - rand) * 0.05

      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'actions::post',
          :sync => true,
          :can_write => true,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :batch_count => GeographOptions[:batch_add_posts][:count] || 1,
          :batch_radius => GeographOptions[:batch_add_posts][:radius] || 0,
          :user => { :id => @agent.id }
        }
      }

      return result
    end

    def read_post opts
      lat = opts[:latitude].to_s.to_f + (0.5 - rand) * 0.1
      lon = opts[:longitude].to_s.to_f + (0.5 - rand) * 0.1

      result = {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'read_post',
          :sync => true,
          :can_write => false,
          :latitude => lat,
          :longitude => lon,
          :locality_hint => locality_value(lat, lon),
          :user => { :id => @agent.id }
        }
      }
      return result
    end

    def move_params opts
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'track_current',
          :sync => true,
          :can_write => true,
          :data => {
            :type => "Mover",
            :body => "Mover with position\n <#{opts[:latitude].to_s}, #{opts[:longitude].to_s}>"
          },
          :user => { :id => @agent.id }
        }.merge(opts)
      }
    end

    def destroy_agent_params opts = {}
      lat = @current_pos ? @current_pos[:latitude] : @agent.initial_latitude
      lon = @current_pos ? @current_pos[:longitude] : @agent.initial_longitude
      return {
        :cmd => REMOTE_ACTION_NAME,
        :data => {
          :cmd => 'destroy_agent',
          :sync => true,
          :can_write => true,
          :locality_hint => locality_value(lat, lon),
          :user => { :id => @agent.id }
        }.merge(opts)
      }
    end

end

