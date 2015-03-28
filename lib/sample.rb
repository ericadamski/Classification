require 'random_vector'

class Sample

  attr_accessor :size

  def initialize (count = 2000)
    @size = count
  end

  def generate_samples (probabilities)
    samples = []
    @size.times do
      result = []
      for pr in probabilities do
        val = rand
        result.push(pr <= val ? 0 : 1)
      end
      samples.push result
    end
    samples
  end

  def generate_samples_from_tree (tree)
    #tree is the features list from the tree structure
    samples = []
    @size.times do
      result = Hash.new
      for node in tree do
        val = rand
        if result.empty?
          result[:"#{node}"] = (node.pr_one <= val ? 0 : 1)
        else
          prev_val = result[:"#{node.parent}"]

          if prev_val == 1
            result[:"#{node}"] = (node.pr_one <= val ? 0 : 1)
          else
            result[:"#{node}"] = (node.pr_zero <= val ? 0 : 1)
          end
        end
      end
      samples.push result.values
    end
    samples
  end

end
