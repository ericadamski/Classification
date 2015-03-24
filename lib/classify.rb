class Classify

  attr_accessor :trainning_data, :samples, :testing_data

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
  end

  def independent_bayesian_classification
  end

  def dependent_bayesian_classification
  end

  def decision_tree_classification
  end
  
end
