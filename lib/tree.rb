require 'node'
require 'edge'
require 'union_find'
require 'graphviz'

class Tree

  attr_accessor :features, :decision_tree, :type

  def initialize (name = 'Class')
    @features = [] #size of ten always and values are binary
    @type = name
    generate
  end

  def get_all_edges
    edges = []
    for nodes in @features do
      edges.push( nodes.adj_list )
    end
    edges.flatten
  end

  def output (file = "/../output/#{@type}#{rand}.png")
    edges = get_all_edges

    for node in @features do
      edges.push Edge.new(node, node.parent) unless node.parent.nil?
    end if edges.empty?

    g = GraphViz.new( :G, :type => :graph )

    @features.each { |node|
      g.add_node node.id.to_s
    }

    edges.each { |edge|
      g.add_edge edge.to.id.to_s, edge.from.id.to_s
    }

    g.output :png => (File.expand_path(File.dirname(__FILE__)) + file)
  end

  def generate
    #generate 10 nodes
    for i in 1..10 do
      if i == 1
        @features.push Node.new(i)
      else
        @features.push Node.new(i, false, @features.sample)
      end
    end
  end

  def get_maximum_spanning_tree
    #create the maximum spaning tree
    #  negate all the weights, run kruskals' algo
    mst = kruskal

    for node in @features do
      node.adj_list.select! { |edge| mst.include? edge }
    end
    mst
  end

  def kruskal
    mst = []
    edges = get_all_edges.map { |edge|
      edge.weight = -edge.weight
      edge
    }.sort_by { |edge| edge.weight }
    union_find = UnionFind.new(@features)
    while edges.any? && mst.size <= @features.size
      edge = edges.shift
      if !union_find.connected? edge.from, edge.to
        union_find.union edge.from, edge.to
        mst << edge
      end
    end
    mst.map { |edge|
      edge.weight = -edge.weight
      edge
    }
  end
end
