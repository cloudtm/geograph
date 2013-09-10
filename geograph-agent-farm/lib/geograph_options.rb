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

class GeographOptions
  include Singleton

  class << self

    def [] key
      @options[key.to_sym]
    end

    private

    # Loads the game configuration maintained in config/game_options.yml
    def init
      @options = {}
      @options_path = File.join(Rails.root, 'config', 'geograph_options.yml')
      load_options
    end

    # Called by init to load the configuration file.
    def load_options
      raise "Cannot find game options file at #{@options_path}" unless File.file?(@options_path)
      @options = File.open(@options_path) { |yf| YAML::load(yf) }
    end

  end

  # Initialize automatically (at constantize) the class object!
  init
  
end
