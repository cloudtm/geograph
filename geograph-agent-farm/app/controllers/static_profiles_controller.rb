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

class StaticProfilesController < ApplicationController
	before_filter :authenticate_agent
	respond_to :js, :html
	around_filter :transact, :only => [:create_with_group]

	def create
		last_position = StaticProfile.max_position(current_user.current_profile_id)
    static_profile = current_user.current_profile.static_profiles.create(
      :duration => params[:duration],
      :position => last_position + 1      
    )
    render :index, :layout => false
	end

	def create_with_group
		last_position = StaticProfile.max_position(current_user.current_profile_id)
    static_profile = current_user.current_profile.static_profiles.create(
      :duration => params[:duration],
      :position => last_position + 1      
    )

    agent_groups = CloudTm::AgentGroup.all
    agent_groups.each do |g|
      static_profile.agent_groups.create(:simulator => g.agents_type, :sleep => g.delay, 
          :track_filter_type => g.track_filter_type, :track_filter_value => g.track_filter_value,
          :threads => g.agents.size)
    end
    
		render :index, :layout => false
	end

	def update
		@static_profile = StaticProfile.find params[:id]
    @static_profile.update_attributes(params[:static_profile])
    flash.now[:notice] = 'Static Profile updated'
    render :index, :layout => false
	end

	def destroy
		static_profile = StaticProfile.find params[:id]
    AgentGroup.where(:static_profile_id => static_profile.id).each do |agent_group|
      agent_group.destroy
    end
    static_profile.destroy
    flash.now[:notice] = 'Static Profile deleted'
    render :index, :layout => false
	end

	def sort
		params[:ids].each_with_index do |profile_id, index|
      static_profile = StaticProfile.find_by_id(profile_id)
      static_profile.update_attribute(:position, index + 1) if static_profile
    end
    render :index, :layout => false
	end

	def new_group
		static_profile = StaticProfile.find params[:id]
		@agent_group = static_profile.agent_groups.create
		render :layout => false
	end

	def edit_groups
		@static_profile = StaticProfile.find params[:id]
		render :layout => false
	end

	def update_groups
		group = AgentGroup.find(params[:id])
		group.update_attribute(params[:attribute], params[:value])
		flash.now[:notice] = "Agent group modified."
		render :index, :layout => false
	end

	def update_groups_full
		group = AgentGroup.find(params[:id])
		group.update_attributes(params[:attributes])
		flash.now[:notice] = "Agent group modified."
		render :index, :layout => false
	end

	def destroy_group
		group = AgentGroup.find(params[:id])
		group.destroy
		flash.now[:notice] = "Agent group deleted."
		render :index, :layout => false
	end

	private


  def transact
    CloudTm::FenixFramework.getTransactionManager.withTransaction do
      yield
    end
  end

end
