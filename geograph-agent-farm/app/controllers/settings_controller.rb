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

class SettingsController < ApplicationController
  before_filter :create_settings
  respond_to :js, :html

  def map
    current_user.setting.map_url = params[:map_url]
    current_user.setting.save!
    render :layout => false
  end

  def stats
    setting = current_user.setting
    setting.stats_url = params[:stats_url]
    Rails.logger.debug("Saving stats url #{params[:stats_url]}")
    setting.save!
    setting.reload
    Rails.logger.debug("Saved stats url #{setting.stats_url}")
    render :layout => false
  end

  def landmark_stats
    setting = current_user.setting
    setting.landmark_stats_url = params[:landmark_stats_url]
    Rails.logger.debug("Saving landmark stats url #{params[:landmark_stats_url]}")
    setting.save!
    setting.reload
    Rails.logger.debug("Saved landmark stats url #{setting.landmark_stats_url}")
    render :layout => false
  end


  def create_settings
    current_user.setting = Setting.create() unless current_user.setting
    current_user.save!
  end
end
