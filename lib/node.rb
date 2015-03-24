class Node

  attr_accessor :pr_one, :adj_list, :pr_zero, :is_root, :parent

  def initialize (root = false, parent = nil)
    @pr_one   = rand
    @pr_zero  = 1 - @pr_one
    @adj_list = [] # List of all edges coming from this node
    @is_root  = root
    @parent   = parent
  end

  def add_to_adj_list (edge)
    @adj_list.push edge
  end

  def get_sorted_edges
    @adj_list.sort_by { |edge| edge.weight }
  end

  def get_inverted_edge_weights
    @adj_list.map { |edge|
      edge.weight = -edge.weight
    }
  end

  def root?
    @is_root
  end

end
