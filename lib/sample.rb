require 'random_vector'

class Sample

  attr_accessor :size

  def initialize (count = 2000)
    @size = count
  end

  def generate_samples (probabilities)
    samples = []
    @size.times do
      val = rand
      result = []
      for pr in probabilities do
        result.push(pr <= val ? 0 : 1)
      end
      samples.push result
    end
    samples
  end

  def generate_samples_from_tree (tree)
    samples = []
    for i in [1..@size] do

    end
    samples
  end

end
