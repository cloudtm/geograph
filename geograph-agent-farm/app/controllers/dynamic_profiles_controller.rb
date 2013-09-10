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

class DynamicProfilesController < ApplicationController
  respond_to :js, :html

  def new
      @dynamic_profile = DynamicProfile.new
      render :layout => false
  end

  def create
      @dynamic_profile = DynamicProfile.create({:name => params[:name], :iterations => 1}.merge({:user_id => current_user.id}))
      current_user.current_profile = @dynamic_profile
      current_user.save!
      render :layout => false
      #render 'farm/console'
  end


end
