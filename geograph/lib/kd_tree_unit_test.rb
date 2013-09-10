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

require './kd_tree'

def dist2 n1, n2
  (n1[0] - n2[0]) ** 2 + (n1[1] - n2[1]) ** 2
end

kdt = KdTree.new(KdTree::SimpleNodeFactory.new(KdTree::ArrayNode), KdTree::ArraySamplePackager)
samples = []
100.times do
  samples << [rand(0..100), rand(0..100)]
end
kdt.add_samples samples

query = [rand(0..100), rand(0..100)]
knn = kdt.knn query, 5, [ :unwrap_samples ]

puts "Query: #{query.inspect}"
knn.each do |n| 
  puts "KNN: #{n.inspect}, dist = #{dist2 n, query}"
end
samples.sort! { |n1, n2| dist2(n1, query) <=> dist2(n2, query) }

samples.each do |s| 
  puts "SAMPLE: #{s.inspect}, dist = #{dist2 s, query}"
end

