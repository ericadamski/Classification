require 'tree'
require 'graphviz'

OUTPUT_DIR = File.expand_path(File.dirname(__FILE__))+'/../output/'

class Classify

  attr_accessor :trainning_data,
    :samples,
    :testing_data,
    :classifying_vector,
    :classifying_tree,
    :trainning_index

  def initialize (samples, is_dt = false)
    @samples = samples
    @trainning_data = Hash.new
    @testing_data = Hash.new
    seperate_data
    @trainning_index = rand(@trainning_data.size)
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
  end

  def train (_in = @trainning_index)
    result = Array.new(10,0)
    @trainning_index = _in
    for i in 0..trainning_data[_in].first().size-1 do
      result[i] = get_probability i
    end
    @classifying_vector = result
  end

  def train_dependent
    # get all the children of the current node in the DT
    # calculate the prs of all the children based on the according values given
    # by the parent

    # start at the root, this way we can gaurentee that the parent will always
    # have a value associated

    for node in @classifying_tree.features do
      if node.parent.nil?
        # root
        node.pr_one = get_probability(node.id - 1)
      else
        child_zero = 0
        child_one  = 0
        x = node.parent.id - 1
        y = node.id - 1
        for sample in trainning_data do
          for vector in sample[1] do
            if vector[x] == 0 and vector[y] == 0
              child_zero  += 1 #0
            elsif vector[x] == 1 and vector[y] == 0
              child_one += 1 #0
            end
          end
          child_zero = child_zero.to_f / sample[1].size
          child_one  = child_one.to_f / sample[1].size
        end
        node.pr_one  = child_one
        node.pr_zero = child_zero
      end
    end
  end

  def set_parents (mst, parent)
    children = mst.select { |edge| edge.from == parent }.map { |edge| edge.to }
    for child in children do
      child.parent = parent
      set_parents mst, child
    end
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
      for node in copy do
        first.add_to_adj_list Edge.new(first,
          node,
          calculate_weight(first.id - 1, node.id - 1))
      end
    end

    mst = tree.get_maximum_spanning_tree

    mst_vertices = (mst.map { |edge| edge.from } +
      mst.map { |edge| edge.to }).uniq

    set_parents mst, tree.features.first

    tree.output '/../output/infered.png'

    @classifying_tree = tree

    train_dependent
  end

  def calculate_weight (x, y)
    # go through all the samples, only summing in positions x and y
    # puts "x : #{x}, y : #{y}"
    pxy, px, py = 0, 0, 0

    size = trainning_data.first()[1].size

    for sample in trainning_data do
      for vector in sample[1] do
        px += vector[x]
        py += vector[y]

        if vector[x] == 1 and vector[y] == 1
          pxy += 1
        end
      end
      px  = px.to_f/size
      py  = py.to_f/size
      pxy = pxy.to_f/size
    end
    (pxy * (Math.log(pxy/(px*py))))
  end

  def get_probability (pos)
    sum = 0
    for vector in trainning_data[@trainning_index] do
        sum += vector[pos]
    end
    sum = sum.to_f / trainning_data[@trainning_index].size
  end

  def accuracy (_in = @trainning_index)
    train _in
    #puts "#{trainning_data[@trainning_index]}"
    #puts "#{@classifying_vector}"
    return lambda { |vector|
      independent_bayesian_classification vector
    }
  end

  def independent_bayesian_classification (vector)
    #if 1 take 1-p other wise take p and product of them
    conf = 1.0
    for i in 0..vector.size - 1 do
      if vector[i] == 1
        conf *= 1 - @classifying_vector[i]
      else
        conf *= @classifying_vector[i]
      end
    end
    conf
  end

  def dependent_bayesian_classification (vector)
    #this is from the tree ><
    conf = 1
    for node in @classifying_tree.features do
      if node.parent.nil?
        conf *= node.pr_one
      else
        conf *= node.pr_one  if vector[node.parent.id - 1] == 1
        conf *= node.pr_zero if vector[node.parent.id - 1] == 0
      end
    end
    conf
  end

  def decision_tree_classification (vector)
    #this is from the tree
  end

end
