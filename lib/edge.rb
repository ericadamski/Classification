class Edge

  attr_accessor :weight, :from, :to

  def initialize (from, to, weight)
    @weight = weight
    @from = from
    @to = to
  end

end
