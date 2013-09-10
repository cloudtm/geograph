###############################################################################
################################################################################
##
## This file is part of GeoGraph.
##
## Copyright (c) 2012 Algorithmica Srl
##
## GeoGraph is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## GeoGraph is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
##
## Contact us via email at info@algorithmica.it or at
##
## Algorithmica Srl
## Largo Alfredo Oriani 12
## 00152 Rome, Italy
##
################################################################################
################################################################################

# KD-Tree for Ruby
# by Daniele "MadMage" Calisi
# © 2013 Algorithmica S.r.l.

# see https://github.com/gurgeous/kdtree (from http://gurge.com/2009/10/22/ruby-nearest-neighbor-fast-kdtree-gem/)
# for inspirations
# see https://github.com/MagLev/maglev/tree/master/examples/persistence/kdtree (from http://maglevity.wordpress.com/2009/12/17/kd-trees-and-maglev/)
# for inspirations
# see http://www.ruby-forum.com/topic/134477
# for SortedArray implementation

# This tree expects to be initialized with a factory object with a function factory that instantiate a Node object.
# A Node object is expected to have at least the following methods: sample, split_dim, enabled, dist2sample, left and right; 
#   left and right must be initially nil, enabled should be true for all nodes except those you do not want to be returned by queries, dist2sample must be reset to 0
#   before each search
# You can insert samples into the tree, each sample is an object that is expected to have at least the following methods: [], dist2

class KdTree

  class ArraySampleWrapper
    def initialize ary
      @data = ary
    end

    def [] i
      @data[i]
    end

    def dist2 other
      (@data[0] - other[0]) ** 2 + (@data[1] - other[1]) ** 2
    end

    def unwrap
      @data
    end
  end

  class IdentitySamplePackager
    def self.wrap obj
      obj
    end
  end

  class ArraySamplePackager
    def self.wrap obj
      ArraySampleWrapper.new obj
    end
  end

  class ArrayNode
    attr_accessor :sample, :split_dim, :enabled, :left, :right
    def initialize
      @sample = nil
      @split_dim = 0
      @enabled = true
      @left = nil
      @right = nil
    end
  end

  class SimpleNodeFactory
    def initialize klass
      @klass = klass
    end
    def factory
      @klass.new
    end
  end

  class SortedArray < Array
    def self.[] *array
      SortedArray.new(array)
    end

    def initialize array = nil
      super(array.sort) if array
      @tree = nil
    end

    def set_tree tree
      @tree = tree
    end

    def << node
      insert index_of_last_LE(node), node
    end

    alias push <<
    alias shift <<

    def index_of_last_LE node
      l, r = 0, length - 1
      while l <= r
        m = (r + l) / 2
#        if node.dist2sample < self[m].dist2sample
#        Madmass.logger.error "KD-TREE dist1=#{@tree.dist2sample(node.object_id)}, dist2=#{@tree.dist2sample(self[m].object_id)}"
        if @tree.dist2sample(node.object_id) < @tree.dist2sample(self[m].object_id)
          r = m - 1
        else
          l = m + 1
        end
      end
      return l
    end
  end

  def initialize node_factory, sample_packager = IdentitySamplePackager
    @node_factory = node_factory
    @sample_packager = sample_packager
    @dist2sample = { }
    clear
  end

  def to_s
    @root ? to_s0(@root) : ''
  end

  def clear
    @root = nil
  end

  def set_root the_root
    @root = the_root
  end

  def get_root
    @root
  end

  def add_sample sample
#    Madmass.logger.error "KD-TREE adding sample #{sample}"
#t = Time.new
    add_samples [sample]
#Madmass.logger.error "ABRACADABRA #{(Time.new - t).to_f}"
  end

  def add_samples samples
    if not @root
      @root = init_samples0 samples, 0
    else
      samples.each do |s|
        if not @root
          new_node = @node_factory.factory
          new_node.sample = @sample_packager.wrap(s)
          new_node.split_dim = 0
          new_node.enabled = true
        else
          add_sample0 s, @root, 0
        end
      end
    end
  end

  # possible opts are :return_nodes (returns the nodes, instead of the associated samples), :unwrap_samples (calls unwrap on the samples when returning samples)
  def nearest_neighbour query, opts = [ ]
    @dist2sample = { }
    @n_node = nil
    @n_dist = nil
    @visited_nodes = 0
    nearest_neighbour0 query, @root
    #Madmass.logger.error "KD-TREE VISITED NODES (nn) #{@visited_nodes}"
    if not @n_node
      nil
    else
      if opts.include?(:return_nodes)
        @n_node
      elsif not opts.include?(:unwrap_samples)
        @n_node.sample
      else
        @n_node.sample.unwrap
      end
    end
  end

  def k_nearest_neighbours query, count, opts = [ ]
    @dist2sample = { }
    @n_nodes = SortedArray.new
    @n_nodes.set_tree self
    @n_dist = nil
    @visited_nodes = 0
    t1 = Time.new
    k_nearest_neighbours0 query, @root, count
    t2 = Time.new
    #Madmass.logger.error "KD-TREE VISITED NODES #{@visited_nodes - 1} TIME: #{(t2 - t1).to_f}"
    if opts.include?(:return_nodes)
      @n_nodes
    elsif not opts.include?(:unwrap_samples)
      @n_nodes.map { |n| n.sample }
    else
      @n_nodes.map { |n| n.sample.unwrap }
    end
  end

  def dist2sample id
    if not @dist2sample[id]
#      Madmass.logger.error "KD-TREE Trying to take the dist2sample of an unknown node #{id}"
      0.0
    else
      @dist2sample[id]
    end
  end

  def all opts = [ ]
    ret = all0 @root
    if opts.include?(:return_nodes)
      ret
    elsif not opts.include?(:unwrap_samples)
      ret.map { |n| n.sample }
    else
      ret.map { |n| n.sample.unwrap }
    end
  end

  def rebalance
    samples = all
    #Madmass.logger.error "KD-TREE aho #{samples} #{samples[0]}"
    @root = init_samples0 samples, 0
  end

  alias <<  add_sample
  alias nn  nearest_neighbour
  alias knn k_nearest_neighbours

  private
  def all0 kdn
    r = [ kdn ] if kdn
    if kdn.left
      r += all0 kdn.left
    end 
    if kdn.right
      r += all0 kdn.right
    end 
    r   
  end

  def add_sample0 sample, node, split_dim
    if sample[split_dim] <= node.sample[split_dim]
      if not node.left
        new_node = @node_factory.factory
        new_node.sample = @sample_packager.wrap(sample)
        new_node.split_dim = (split_dim + 1) % 2
        new_node.enabled = true
        node.left = new_node
      else
        add_sample0 sample, node.left, (split_dim + 1) % 2
      end
    else
      if not node.right
        new_node = @node_factory.factory
        new_node.sample = @sample_packager.wrap(sample)
        new_node.split_dim = (split_dim + 1) % 2
        new_node.enabled = true
        node.right = new_node
      else
        add_sample0 sample, node.right, (split_dim + 1) % 2
      end
    end
  end

  def init_samples0 sample_set, split_dim
    if sample_set.empty?
      tree = nil
    elsif sample_set.size == 1
      tree = @node_factory.factory
      tree.sample = @sample_packager.wrap(sample_set[0])
      tree.split_dim = split_dim
      tree.enabled = true
    else
      tree = @node_factory.factory
      tree.split_dim = split_dim
      tree.enabled = true
      sample_set.sort! { |n1, n2| n1[split_dim] <=> n2[split_dim] }
      pivot_id = sample_set.size / 2
      tree.sample = @sample_packager.wrap(sample_set[pivot_id])
      split_dim = (split_dim + 1) % 2
      tree.left = init_samples0 sample_set[0..pivot_id-1], split_dim
      tree.right = init_samples0 sample_set[pivot_id+1..-1], split_dim
    end
    tree
  end

  def nearest_neighbour0 query, cur_node
    if not cur_node
      return nil
    end
    @visited_nodes += 1
    ad = query[cur_node.split_dim] - cur_node.sample[cur_node.split_dim]
    if ad <= 0
      near = cur_node.left
      far = cur_node.right
    else
      near = cur_node.right
      far = cur_node.left
    end

    nearest_neighbour0 query, near
    if !@n_dist || ad * ad < @n_dist
      nearest_neighbour0 query, far
    end

    if cur_node.enabled
      d = cur_node.sample.dist2 query
      if !@n_dist || d < @n_dist
        @n_node = cur_node
        @n_dist = d
      end
#      dx = (query[0] - cur_node.sample[0]) ** 2
#      if not @n_dist or dx < @n_dist
#        d = dx + (query[1] - cur_node.sample[1]) ** 2
#        if not @n_dist or d < @n_dist
#          @n_node = cur_node
#          @n_dist = d
#        end
#      end
    end
  end

  def k_nearest_neighbours0 query, cur_node, count
    count = 3
    if not cur_node
      return nil
    end
    @visited_nodes += 1
    ad = query[cur_node.split_dim].to_f - cur_node.sample[cur_node.split_dim].to_f
    if ad <= 0
      near = cur_node.left
      far = cur_node.right
    else
      near = cur_node.right
      far = cur_node.left
    end

    #Madmass.logger.error "KD-TREE cur_node: #{cur_node.inspect} #{cur_node.sample[0]},#{cur_node.sample[1]}, query: #{query[0]},#{query[1]}..#{@n_dist}"

    k_nearest_neighbours0 query, near, count
    if !@n_dist || ad * ad < @n_dist
      #Madmass.logger.error "KD-TREE going into far because #{ad * ad} < #{@n_dist}"
      k_nearest_neighbours0 query, far, count
    end

    if cur_node.enabled
      d = cur_node.sample.dist2 query
      if @n_nodes.size < count or not @n_dist or d < @n_dist
        @dist2sample[cur_node.object_id] = d
        cur_node.dist2sample = d
        if @n_nodes.size >= count
          @n_nodes.delete(@n_nodes.last)
        end
        #Madmass.logger.error "KD-TREE CURRENT:"
        @n_nodes << cur_node
#        @n_dist = @n_nodes.last.dist2sample
        @n_nodes.each do |n|
          #Madmass.logger.error "KD-TREE -- #{n.sample[0]},#{n.sample[1]} -- #{n.object_id} dist=#{@dist2sample[n.object_id]}"
        end
        @n_dist = dist2sample(@n_nodes.last.object_id)
      end
#      dx = (query[0].to_f - cur_node.sample[0].to_f) ** 2
#      if @n_nodes.size < count or not @n_dist or dx < @n_dist
#        d = dx + (query[1].to_f - cur_node.sample[1].to_f) ** 2
#        if @n_nodes.size < count or not @n_dist or d < @n_dist
#          cur_node.dist2sample = d
#          if @n_nodes.size >= count
#            @n_nodes.delete(@n_nodes.last)
#          end
#          @n_nodes << cur_node
#          @n_dist = @n_nodes.last.dist2sample
#        end
#      end
    end
  end

  def to_s0 node
    if not node
      return ''
    else
      s = node.sample.inspect + "  #{node.sample[0]},#{node.sample[1]} (sd=#{node.split_dim})\n"
      if node.left then s +=  "  left:  #{node.left.sample.inspect} #{node.left.sample[0]},#{node.left.sample[1]}\n" end
      if node.right then s += "  right: #{node.right.sample.inspect} #{node.right.sample[0]},#{node.right.sample[1]}\n" end
      if node.left then s += to_s0 node.left end
      if node.right then s += to_s0 node.right end
      return s
    end
  end
end
