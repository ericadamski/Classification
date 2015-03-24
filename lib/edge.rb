class Edge

  attr_accessor :weight, :head, :tail

  def initialize (head, tail, weight)
    @weight = weight
    @tail = tail
    @head = head
  end

end
