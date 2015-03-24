class Node

  attr_accessor :pr_occur, :adj_list

  def initialize
    @pr_occur = rand
    @adj_list = [] # List of all edges coming from this node
  end

  def add_to_adj_list (edge)
    @adj_list.push edge
  end

end
