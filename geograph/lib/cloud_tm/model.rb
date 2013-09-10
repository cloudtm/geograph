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

require "#{Rails.root}/lib/geograph_options"

module CloudTm
  class DomainRootCache
    @@app = nil

    def self.getApp
      if GeographOptions[:l2_cache][:enabled]
        @@app = FenixFramework.getDomainRoot().getAppCached(false) unless @@app
      else
        @@app = FenixFramework.getDomainRoot().getApp unless @@app
      end
      @@app
    end

    def self.readonly_action
      Thread.current[:readonly_action].nil? ? false : Thread.current[:readonly_action]
    end

    def self.readonly_action= b
      Thread.current[:readonly_action] = b
    end

  end
end

module CloudTm
  module Model

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def domain_root
#        FenixFramework.getDomainRoot().getApp
        CloudTm::DomainRootCache.getApp
      end

      def where(options = {})
        instances = []
        all.each do |instance|
          instances << instance if instance.has_properties?(options)
        end
        return instances
      end

      def find_by_id(id)
        FenixFramework.getDomainObject(id)
      end

      def all
        # must be implemented in the models
        []
      end

      def create attrs = {}, &block
        Rails.logger.debug "CREATE FOR DML MODEL: #{attrs.inspect}"
        if(attrs[:locality_key] and attrs[:locality_value])
          Rails.logger.debug "CloudTm::Model::create: with locality hints: key: #{attrs[:locality_key]} - value: #{attrs[:locality_value]}"
          instance = new new_locality_hint(attrs.delete(:locality_key), attrs.delete(:locality_value))
        else
          instance = new
        end
        attrs.each do |attr, value|
          if attr != :locality_key and attr != :locality_value
            instance.send("#{attr}=", value)
          end
        end
        # manager.save instance
        block.call(instance) if block_given?
        instance
      end

      def new_locality_hint(key, value)
         lochints = Java::EuCloudtm::LocalityHints.new
         lochints.addHint(key, value)
         s = value.split(',')
         if s.size == 2
            lochints.addHint('x', s[0])
            lochints.addHint('y', s[1])
         end
         lochints
      end

    end

    # Offers the access to the domain root for instances.
    # Uses the class method with the same name.
    def domain_root
      self.class.domain_root
    end

    def id
      getExternalId
    end

    def update_attributes attrs = {}
      attrs.each do |property, value|
        send("#{property}=", value)
      end
    end

    def has_properties?(options)
      options.each do |prop, value|
        return false if send(prop) != value
      end
      true
    end

    def to_json
      attributes_to_hash.to_json
    end

    def new_locality_hint(key, value)
      self.class.new_locality_hint(key, value)
    end

  end
end
