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
class GeographRequestProcessor
  java_implements 'Java::PtIstFenixframework::Messaging::RequestProcessor'
  def on_request req
#    Madmass.logger.error "[LARD] received #{req}"
    req = JSON.parse(req)
    req.delete('agent')
    req.delete('sync')
    req.delete('canWrite')
    req.delete('can_write')
#    Madmass.logger.error "[LARD] parsed message #{req.to_yaml}"
    Madmass.current_agent = Madmass::Agent::ProxyAgent.new
    Madmass.current_agent.execute req
#    Madmass.logger.error "[LARD] action executed"
    resp = Madmass.current_perception
#    resp = resp.to_yaml
#    resp = YAML::parse(resp)
#    puts "[LARD] Response is #{resp.to_yaml}"
    begin
      resp = resp.to_json
    rescue Exception => ex
      Rails.logger.error "Cannot convert to JSON this: #{resp.to_yaml}\nERROR: #{ex}"
      Rails.logger.error ex.backtrace.join("\n")
    end
#    Madmass.logger.error "[LARD] ...jsonized: #{resp}"
    resp
  end
end

require File.join(Rails.root, 'lib', 'cloud_tm', 'framework')
ok = false
while !ok do
  begin
    # loading the Fenix Framework
    Madmass.logger.debug "[initializers/cloud_tm] Initializing Framework"
    CloudTm::Framework.init
    Madmass.logger.debug "[initializers/cloud_tm] Framework Initialized"
    ok = true
  rescue Exception => ex
    Rails.logger.error "Cannot initialize Fenix Framework... but we will retry in 2 seconds"
    sleep 2.0
  end
end

begin
  reqProc = GeographRequestProcessor.new
  CloudTm::FenixFramework.registerReceiver reqProc
#  obj = { this: 'is an', object: { with: 'sub', object: 'and' }, other: 'objects' }
#  resp = CloudTm::FenixFramework.sendRequest obj.to_json, nil, 'geograph', true
#  resp = JSON.parse(resp, symbolize_names: true)
#  Madmass.logger.error "[LARD] received this #{resp}"
rescue Exception => ex
  Rails.logger.error "Cannot load Cloud-TM Framework: #{ex}"
  Rails.logger.error ex.backtrace.join("\n")

  Madmass.logger.error "*********** LOOKING FOR CAUSES ************"
  current = ex
  while current
    Madmass.logger.error("Inspecting cause: #{current.class} --  #{current.message}")
    Madmass.logger.error current.backtrace.join("\n")
    current = current.class.method_defined?(:cause) ? current.cause : nil
  end
end
