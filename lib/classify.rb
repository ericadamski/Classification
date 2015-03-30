require 'tree'
require 'node'
require 'json'
require 'graphviz'

OUTPUT_DIR = File.expand_path(File.dirname(__FILE__))+'/../output/'

class Classify

  attr_accessor :classes,
    :trainning_index

  def initialize (classes, index = 8)
    @classes = classes #list
    @classes.map { |c| seperate_data c }
    @trainning_index = rand(index)
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

  def infer_dependence_tree (_class, size)
    # take the first node.
    # let its position in the features vecture be denoted by 0
    # select the next node, its position is called 0 + 1
    # take count the occurences of 1's in both the 0th and 0 + 1th places
    #  to get p(x,y) individually, p(x) is count of 0 and p(y) is 0 + 1
    tree = Tree.new size

    copy = tree.features.slice(0, tree.features.size)

    while copy.any?
      first = copy.pop
      for node in copy do
        first.add_edge Edge.new(first,
          node,
          calculate_weight(_class, first.id - 1, node.id - 1))
      end
    end

    mst = tree.get_maximum_spanning_tree

    set_parents mst, tree.features.first

    tree.output "/../output/infered_#{_class[:type].to_s}.png"

    train_dependent _class, tree

    _class[:dependence_tree] = tree
  end

  def calculate_weight (_class, x, y)
    # go through all the samples, only summing in positions x and y
    # puts "x : #{x}, y : #{y}"
    pxy, px, py = 0, 0, 0

    size = _class[:trainning_data][@trainning_index].size

    for vector in _class[:trainning_data][@trainning_index] do
      px += vector[x]
      py += vector[y]
      pxy += 1 if vector[x] == 1 and vector[y] == 1
    end

    px  = px.to_f/size
    py  = py.to_f/size
    pxy = pxy.to_f/size

    val = (pxy * (Math.log(pxy/(px*py), 2)))
    val.nan? ? -1200000 : val
  end

  def get_probability (pos, _class)
    sum = 0
    for vector in _class[:trainning_data][@trainning_index] do
      sum += vector[pos]
    end
    sum.to_f / _class[:trainning_data][@trainning_index].size
  end

  def get_accuracy (dependent = false, size = 10)
    results = Hash.new
    # Structure of Result
    # => { class.id => { count, precent } }
    if dependent.eql? 'DT'
      @classes.map { |c|
        results[c[:type]] = { :type => 'Decision Tree',
          :count => 0,
          :percent => 0.0 }
      }

      for _class in @classes do
        test_set = _class[:testing_data][@trainning_index]
        for vector in test_set do
          for c in @classes do
            val = decision_tree_classification c, vector
            if val.eql? 'YES' and c == _class
              results[_class[:type]][:count] += 1
            end
          end
        end
        results[_class[:type]][:percent] =
          (results[_class[:type]][:count].to_f / test_set.size) * 100
      end
    elsif dependent
      @classes.map { |c|
        infer_dependence_tree c, size

        results[c[:type]] = { :type => 'Dependence Tree',
          :count => 0,
          :percent => 0.0 }
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
            results[_class[:type]][:count] += 1
          end
        end
        results[_class[:type]][:percent] =
          (results[_class[:type]][:count].to_f / test_set.size) * 100
      end
    else #independent
      @classes.map { |c|
        train @trainning_index, c

        results[c[:type]] = { :type => 'Independent',
          :count => 0,
          :percent => 0.0 }
      }

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
            results[_class[:type]][:count] += 1
          end
        end
        results[_class[:type]][:percent] =
          (results[_class[:type]][:count].to_f / test_set.size) * 100
      end
    end
    results
  end

  def entropy (_class, set)
    # count positives = 1 and negatives = 0
    # - p+ log p+ - p- log p-
    # p+ = pos/total, p- = neg/total
    pos = set.select { |vec| vec.last == _class[:type] }.size
    neg = set.select { |vec| vec.last != _class[:type] }.size
    total = set.size

    if pos > 0
      val = -((pos.to_f/total)*Math.log(pos.to_f/total, 2) -
        (neg.to_f/total)*Math.log(neg.to_f/total, 2))
    elsif neg > 0
      val = -(neg.to_f/total)*Math.log(neg.to_f/total, 2)
    else
      val = 0
    end
    #puts "entropy = #{val.to_f}"
    val
  end

  def gain (_class, set, attribute)
    #puts "#{set.empty?}"
    # entropy(set) - for every value attribute can take ( in our case 0-1 )
    # do Sv = { s in Set | the attribute in (set s) has value v }
    # (Sv/S * entropy(Sv))
    set_entropy = entropy _class, set

    zero_set = set.select { |vec| vec[attribute] == 0 }
    one_set  = set.select { |vec| vec[attribute] == 1 }

    zero_set_entropy = entropy _class, zero_set
    one_set_entropy  = entropy _class, one_set

    # in general for binary values :
    # gain(S,A) = entropy(s) - ((|S0/S| * entropy(S0)) + (|S1/S| * entropy(S1)))
    g = set_entropy - ( ((zero_set.size/set.size) * zero_set_entropy) +
      ((one_set.size/set.size) * one_set_entropy) )

    #puts "Gain : #{g.to_f}"
    g.to_f().nan? ? 0 : g.to_f
  end

  def create_decision_tree (_class, set)
    # { attribute, gain }
    feature_count = set.first().size - 2 # - 1 to exclude the classification
    dt = Tree.new nil, false

    attributes = []
    for i in 0..feature_count do
      attributes.push ({ :index => i, :gain => 0 })
    end

    nodes = get_dtree _class, set, attributes, nil

    for node in nodes do
      dt.add_node node
    end

    dt.output "/../output/dt_#{_class[:type].to_s}_#{rand}.png"

    #puts "#{_class[:type]}"

    _class[:dt] = dt

    #puts "#{_class[:type]}"

    dt
  end

  def get_dtree (_class, set, attributes, parent, subtree = nil)
    nodes = []

    if attributes.empty? or set.empty?
      # if totally pos YES otherwise NO
      max_node = nil
      if set.empty?
        nodes.push (max_node = Node.new('NO', false, parent))
      else
        pos = set.select { |vec| vec.last == _class[:type] }.size
        neg = set.select { |vec| vec.last != _class[:type] }.size

        if pos == 0
          nodes.push (max_node = Node.new('YES', false, parent))
        else
          nodes.push (max_node = Node.new('NO', false, parent))
        end
      end
    else
      for attribute in attributes do
        attribute[:gain] = gain(_class, set, attribute[:index])
      end

      max = attributes.max_by { |feature| feature[:gain] }

      attributes.delete max
      #create a node and an edge to the parent
      max_node = Node.new(max[:index], (parent.nil? ? true : false) , parent)

      zero = get_dtree(_class,
        set.select { |vec| vec[max[:index]] == 0 },
        attributes,
        max_node,
        'right')
      one  = get_dtree(_class,
        set.select { |vec| vec[max[:index]] == 1},
        attributes,
        max_node,
        'left')

      nodes.push max_node
      nodes.push zero
      nodes.push one
    end

    if not parent.nil?
      case subtree
        when 'left'
          parent.left_st = max_node
        when 'right'
          parent.right_st = max_node
      end
    end

    nodes.flatten
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
    1 - conf
  end

  def decision_tree_classification (_class, vector)
    # zero = right, one = left
    #puts _class[:dt].features
    current_node = _class[:dt].features.first
    for i in 0..vector.size - 1 do
      if current_node.id.eql? 'YES' or current_node.id.eql? 'NO'
        return current_node.id
      else
        if vector[i] == 1
          current_node = current_node.left_st
        else
          current_node = current_node.right_st
        end
      end
    end
    'NO'
  end

end
