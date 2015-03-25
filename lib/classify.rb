require 'tree'
require 'graphviz'

OUTPUT_DIR = File.expand_path(File.dirname(__FILE__))+'/../output/'

class Classify

  attr_accessor :trainning_data, :samples, :testing_data, :classifing_vector

  def initialize (samples)
    @samples = samples
    @trainning_data = Hash.new
    @testing_data = Hash.new
    seperate_data
  end

  def seperate_data
    increment = @samples.size/8
    # drop the first part of the array, put that in testing data
    # put the left over in trainning
    # concat the dropped part on the end, repeat increment many times.
    for i in 0..7 do
      tmp_test = @samples.slice! 0, increment
      @trainning_data[i] = @samples
      @testing_data[i] = tmp_test
      @samples.concat tmp_test
    end

    train
  end

  def train
    result = Array.new(10,0)
    for sample in trainning_data do
      for i in 0..sample[1].first.size-1 do
        for vector in sample[1] do
          result[i] += vector[i]
        end
        result[i] = result[i].to_f/sample[1].size
      end
    end
    @classifing_vector = result
  end

  def infer_dependence_tree
    # take the first node.
    # let its position in the features vecture be denoted by 0
    # select the next node, its position is called 0 + 1
    # take count the occurences of 1's in both the 0th and 0 + 1th places
    #  to get p(x,y) individually, p(x) is count of 0 and p(y) is 0 + 1
    tree = Tree.new

    copy = tree.features.slice(0, tree.features.size)

    x, y = 0

    while copy.any?
      first = copy.pop
      y = x + 1
      for node in copy do
        first.add_to_adj_list Edge.new(first, node, calculate_weight(x, y))
        y += 1
      end
      x += 1
    end

    g = GraphViz.new( :G, :type => :graph )

    tree.features.each { |node|
      g.add_nodes node.to_s
    }

    tree.get_all_edges.each { |edge|
      g.add_edges edge.to.to_s, edge.from.to_s
    }

    g.output :png => "#{OUTPUT_DIR}before_hello_world.png"

    mst = tree.get_maximum_spanning_tree

    mst_vertices = (mst.map { |edge| edge.from } +
      mst.map { |edge| edge.to }).uniq

    #parent = ( mst_vertices - (mst.map { |edge| edge.from } -
    #  mst.map { |edge| edge.to })).first

    #parent.is_root = true
    #parent.parent  = nil

    g = GraphViz.new( :G, :type => :graph )

    mst_vertices.each { |node|
      g.add_nodes node.to_s
    }

    mst.each { |edge|
      g.add_edges edge.to.to_s, edge.from.to_s
    }

    g.output :png => "#{OUTPUT_DIR}hello_world.png"

    #puts "#{parent}"
  end

  def calculate_weight (x, y)
    # go through all the samples, only summing in positions x and y
    # puts "x : #{x}, y : #{y}"
    pxy, px, py = 0, 0, 0
    for sample in trainning_data do
      for vector in sample[1] do
        px += vector[x]
        py += vector[y]

        if vector[x] == 1 and vector[y] == 1
          pxy += 1
        end
      end
      px  = px.to_f/sample[1].size
      py  = py.to_f/sample[1].size
      pxy = pxy.to_f/sample[1].size
    end
    (pxy * (Math.log(pxy/(px*py))))
  end

  def independent_bayesian_classification (vector)
    #if 1 take 1-p other wise take p and product of them
    conf = 1
    for i in 0..vector.size - 1 do
      if vector[i] == 1
        conf *= @classifing_vector[i]
      else
        conf *= 1 - @classifing_vector[i]
      end
    end
    conf
  end

  def dependent_bayesian_classification (vector)
    #this is from the tree ><
  end

  def decision_tree_classification (vector)
    #this is from the tree
  end

end
