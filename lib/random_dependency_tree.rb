require 'binarytree'
require 'binarytreedrawer'

class RandomDependencyTree

  attr_accessor :features, :tree, :type

  def initialize (name = 'Class')
    @features = generate_features #size of ten always and values are binary
    @tree = BinaryTree.new
    @type = name

    ## Pr ##
    @pr_0 = rand # Pr(Xi=0) given parent is 0
    @pr_1 = rand # Pr(Xi=0) given parent is 1
    ## ## ##
  end

  def eval (parent)

  end

  def generate

  end

  def generate_features
    f = []
    count = 10
    while count > 0 do
      f.push (rand(1..2) % 2)
      count -= 1
    end
    f
  end
end
