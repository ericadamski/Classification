class Node

  attr_accessor :pr_occur, :adj_list

  def initialize
    @pr_occur = rand
    @adj_list = [] # List of all edges coming from this node
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

end
