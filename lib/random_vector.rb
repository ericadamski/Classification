class RandomVector

  attr_accessor :probabilities

  def initialize (dimension = 10)
    @dimension = dimension
    @probabilities = []
    generate
  end

  def generate
    @dimension.times do
      @probabilities.push rand
    end
  end

end
