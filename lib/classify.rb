require 'tree'
require 'graphviz'

OUTPUT_DIR = File.expand_path(File.dirname(__FILE__))+'/../output/'

class Classify

  attr_accessor :classes,
    :trainning_index

  def initialize (classes)
    @classes = classes #list
    @classes.map { |c| seperate_data c }
    @trainning_index = rand(8)
  end

  def seperate_data (_class)
    increment = _class[:samples].size/8
    _class[:trainning_data] = [] if _class[:trainning_data].nil?
    _class[:testing_data]   = [] if _class[:testing_data].nil?
    # drop the first part of the array, put that in testing data
    # put the left over in trainning
    # concat the dropped part on the end, repeat increment many times.
    for i in 0..7 do
      tmp_test = _class[:samples].slice! 0, increment
      _class[:trainning_data][i] = _class[:samples]
      _class[:testing_data][i] = tmp_test
      _class[:samples].concat tmp_test
    end
  end

  def train (_in = @trainning_index, _class)
    result = Array.new(10,0)
    @trainning_index = _in
    for i in 0.._class[:trainning_data][_in].first().size - 1 do
      result[i] = get_probability i, _class
    end
    _class[:classifying_vector] = result
  end

  def train_dependent (_class, tree)
    # get all the children of the current node in the DT
    # calculate the prs of all the children based on the according values given
    # by the parent

    # start at the root, this way we can gaurentee that the parent will always
    # have a value associated

    for node in tree.features do
      if node.parent.nil?
        # root
        node.pr_one = get_probability(node.id - 1, _class)
      else
        child_zero = 0
        child_one  = 0
        x = node.parent.id - 1
        y = node.id - 1
        for vector in _class[:trainning_data][@trainning_index] do
          if vector[x] == 0 and vector[y] == 0
            child_zero  += 1 #0
          elsif vector[x] == 1 and vector[y] == 0
            child_one += 1 #0
          end
        end
        node.pr_one  =
          child_zero.to_f / _class[:trainning_data][@trainning_index].size
        node.pr_zero =
          child_one.to_f / _class[:trainning_data][@trainning_index].size
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

  def infer_dependence_tree (_class)
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

    train_dependent _class, tree

    _class[:dependence_tree] = tree
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

  def get_probability (pos, _class)
    sum = 0
    for vector in _class[:trainning_data][@trainning_index] do
        sum += vector[pos]
    end
    sum = sum.to_f / _class[:trainning_data][@trainning_index].size
  end

  def get_accuracy (_in = @trainning_index, dependent = false)
    results = Hash.new
    # Structure of Result
    # => { class.id => { count, precent } }
    if dependent
      @classes.map { |c|
        infer_dependence_tree c

        results[c] = { :count => 0, :percent => 0.0 }
      }

      for _class in @classes do
        test_set = _class[:testing_data][@trainning_index]
        for vector in test_set do
          highest = { :class => nil, :value => 0 }
          for c in @classes do
            val = dependent_bayesian_classification c, vector
            if val > highest[:value]
              highest[:class] = c
              highest[:value] = val
            end
          end
          if highest[:class] == _class
            results[_class][:count] += 1
          end
        end
        results[_class][:percent] =
          (results[_class][:count].to_f / test_set.size) * 100
      end
    else #independent
      index = 0
      @classes.map { |c|
        train @trainning_index, c

        results[index] = { :count => 0, :percent => 0.0 }
        index += 1
      }

      index = 0

      for _class in @classes do
        test_set = _class[:testing_data][@trainning_index]
        for vector in test_set do
          highest = { :class => nil, :value => 0 }
          for c in @classes do
            val = independent_bayesian_classification c, vector
            if val > highest[:value]
              highest[:class] = c
              highest[:value] = val
            end
          end
          if highest[:class] == _class
            results[index][:count] += 1
          end
        end
        results[index][:percent] =
          (results[index][:count].to_f / test_set.size) * 100

        index += 1
      end
    end
    results
  end

  def independent_bayesian_classification (_class, vector)
    #if 1 take 1-p other wise take p and product of them
    conf = 1.0
    for i in 0..vector.size - 1 do
      if vector[i] == 1
        conf *= 1 - _class[:classifying_vector][i]
      else
        conf *= _class[:classifying_vector][i]
      end
    end
    1 - conf
  end

  def dependent_bayesian_classification (_class, vector)
    conf = 1
    for node in _class[:dependence_tree].features do
      if node.parent.nil?
        conf *= node.pr_one
      else
        conf *= node.pr_one  if vector[node.parent.id - 1] == 1
        conf *= node.pr_zero if vector[node.parent.id - 1] == 0
      end
    end
    conf
  end
end
