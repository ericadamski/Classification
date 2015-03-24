require 'binarytree'
require 'binarytreedrawer'
require 'node'
require 'edge'

class RandomDependencyTree

  attr_accessor :features, :tree, :type

  def initialize (name = 'Class')
    @features = [] #size of ten always and values are binary
    @tree = BinaryTree.new
    @type = name
    generate
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
  end

  def kruskal

  end

  def calculateWeight (head, tail)
    sum = 0

    # pr(x,y) = pr(y) * pr(x|y)

  end
end
