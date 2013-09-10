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

begin
  require File.join(Rails.root, 'lib', 'cloud_tm', 'framework')

    # loading the Fenix Framework
    Madmass.logger.debug "[initializers/cloud_tm] Initializing Framework"
    CloudTm::Framework.init

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
