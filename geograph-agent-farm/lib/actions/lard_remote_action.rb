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

module Actions
  class LardRemoteAction < Madmass::Action::Action
    action_params :data, :sync, :can_write, :jms	# note: jms is here only for back compatibilitiy, it is not used

    def initialize params
      super
      @payload = @parameters[:data]
      @canWrite = true
#Madmass.logger.error "[LARDD] #{@parameters[:data][:can_write]}"
      if !@parameters[:data].nil? && @parameters[:data][:can_write] == false then
        @canWrite = false
      end
      @parameters[:data].delete(:can_write)
#      @canWrite = @parameters[:data].delete(:can_write) || true
      @sync = @parameters[:data].delete(:sync) || true
      @localityHint = @parameters[:data].delete(:locality_hint) || ''
#      Madmass.logger.error "[LARD] initialized action with params:\n#{@parameters.to_yaml}"
    end

    def execute
      message = @payload.to_json
      #Madmass.logger.error "[LARD] about to send this: #{message} ### #{message.inspect} ### #{message.to_s} ### #{message.class} ### localityHint=#{@localityHint} ### #{message.to_yaml}"
      t = Time.new
#Madmass.logger.error "[LARD] can write? #{@canWrite}"
      @resp = CloudTm::FenixFramework.sendRequest(message, @localityHint, 'geograph', @sync, @canWrite)
#Madmass.logger.error "LARD: agent #{message['user']['id']}, LARD round-trip #{(Time.new - t).to_f} s"
#      Madmass.logger.error "[LARD] received this: #{@resp.to_yaml}"
#      @resp = YAML::parse(@resp)
      @resp = JSON.parse(@resp, symbolize_names: true)
#      Madmass.logger.error "[LARD] received echo:\n#{@resp.to_yaml}"
    end

    def build_result
      @resp.each do |p|
        percept = Madmass::Perception::Percept.new self
        percept.data = p.respond_to?(:data) ? p.data : p
        Madmass.current_perception << percept
      end
#      Madmass.logger.error "[LARD] received perception:\n#{Madmass.current_perception.to_yaml}"
    end

    def applicable?
      true
#    @agent = CloudTm::Trackable.find_by_user(@parameters[:user][:id])
#    unless @agent
#      why_not_applicable.publish(
#        :name => :post_blog,
#        :key => 'action.post.blog',
#        :recipients => [@parameters[:user][:id]]
#      )
#    end
#    return why_not_applicable.empty?
    end
  end
end

