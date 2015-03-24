require 'binarytree'
require 'binarytreedrawer'
require 'node'
require 'edge'
require 'union_find'

class Tree

  attr_accessor :features, :tree, :type

  def initialize (name = 'Class')
    @features = [] #size of ten always and values are binary
    @tree = BinaryTree.new
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

  def generate
    #generate 10 nodes
    for i in [1..10] do
      @features.push Node.new
    end

    #create undirected edges between all of them
    copy = @features

    while not copy.empty?
      first = copy.pop
      for node in copy do
        first.add_to_adj_list Edge.new(first,
          node,
          calculateWeight(first, node))
      end
    end
  end

  def get_maximum_spanning_tree
    #create the maximum spaning tree and store it in @tree
    #negate all the weights, run kruskals' algo
    mst = kruskal
    #add nodes of mst into tree
    mst.each { |edge|
      @tree.add edge.from
      @tree.add edge.to
    }
  end

  def kruskal
    mst = []
    edges = get_all_edges.map { |edge| edge.weight = -edge.weight }
    union_find = UnionFind.new(@features)
    while edges.any? && mst.size <= @features.size
      edge = edges.shift
      if !union_find.connected? edge.from, edge.to
        union_find.union edge.from, edge.to
        mst << edge
      end
    end
    mst.map { |edge| edge.weight = -edge.weight }
  end

  def calculateWeight (head, tail)
    sum = 0

    # pr(x,y) = pr(y) * pr(x|y)

  end
end
