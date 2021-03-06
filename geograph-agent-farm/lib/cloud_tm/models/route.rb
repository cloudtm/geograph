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

require File.join(Rails.root, 'lib', 'cloud_tm', 'models', 'route_loader')

module CloudTm
  class Route
    include CloudTm::Model
    extend CloudTm::RouteLoader

    def destroy
      FenixFramework.getDomainRoot.getApp.removeRoutes(self)
    end

    class << self

      def find_by_id(oid)
        FenixFramework.getDomainObject(id)
      end

      def create attrs = {}, &block
        instance = super
        instance.set_root FenixFramework.getDomainRoot.getApp
        instance
      end

      #alias_method_chain :create, :root

      def all
        FenixFramework.getDomainRoot.getApp.getRoutes.to_a
      end

    end
  end
end 