class Classify

  attr_accessor :trainning_data, :samples, :testing_data, :classifing_vector

  def initialize (samples)
    @samples = samples
    @trainning_data = Hash.new
    @testing_data = Hash.new
    seperate_data
  end

  def seperate_data
    increment = @samples.size/8
    # drop the first part of the array, put that in testing data
    # put the left over in trainning
    # concat the dropped part on the end, repeat increment many times.
    for i in 0..7 do
      tmp_test = @samples.slice! 0, increment
      @trainning_data[i] = @samples
      @testing_data[i] = tmp_test
      @samples.concat tmp_test
    end

    train
  end

  def train
    result = Array.new(10,0)
    for sample in trainning_data do
      for i in 0..sample[1].first.size-1 do
        for vector in sample[1] do
          result[i] += vector[i]
        end
        result[i] = result[i].to_f/sample[1].size
      end
    end
    @classifing_vector = result
  end

  def independent_bayesian_classification (vector)
    #if 1 take 1-p other wise take p and product of them
    conf = 1
    for i in 0..vector.size - 1 do
      if vector[i] == 1
        conf *= 1 - @classifing_vector[i]
      else
        conf *= @classifing_vector[i]
      end
    end
    conf
  end

  def dependent_bayesian_classification (vector)
  end

  def decision_tree_classification (vector)
  end

end
