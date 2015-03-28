#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__))
require 'tree'
require 'random_vector'
require 'sample'
require 'classify'
require 'real_data'

generator = Sample.new

classes = []
#generate 4 random vectors, each dimension 10
4.times do
  classes.push RandomVector.new
end

#generate 2000 samples
samples = Hash.new # classification vector and samples

for i in 0..3 do
  sam = generator.generate_samples(classes[i].probabilities)
  c = Classify.new sam
  samples["#{i}"] = { :vector => classes[i],
    :samples => sam,
    :classifier => c
  }
end

# classify using independent bayesian classification
test_set = rand(8)

samples.map { |num, set|
  set[:accuracy] = {
    :classify => set[:classifier].accuracy(test_set),
    :count => 0
  }
}

for _class in samples do
  test_data = _class[1][:classifier].testing_data[test_set]
  for vector in test_data do
    highest = { :c => nil, :count => 0 }
    for c in samples do
      val = c[1][:accuracy][:classify].call(vector)
      if val > highest[:count]
        highest[:c] = c[1]
        highest[:count] = val
      end
    end
    if highest[:c] == _class[1]
      highest[:c][:accuracy][:count] += 1
      puts "Winner!"
    end
  end
  _class[1][:accuracy][:count] =
    _class[1][:accuracy][:count].to_f / test_data.size
end

for i in 0..3 do
  puts "Class #{i} has accuracy : #{samples["#{i}"][:accuracy][:count]}"
end

#generate random tree, with random variables, train on 2000 samples
trees = []

4.times do
  trees.push Tree.new
end

tree_samples = Hash.new

for i in 0..3 do
  trees[i].output "/../output/proper-#{i}.png"
  sam = generator.generate_samples_from_tree(trees[i].features)
  tree_samples["#{i}"] = { :tree => trees[i],
    :samples => sam,
    :classifier => Classify.new(sam) }
  tree_samples["#{i}"][:classifier].infer_dependence_tree
end

# take sample fro class 1
sample = tree_samples["0"][:classifier].testing_data[0].sample
# conf for each class return highest
for i in 0..3 do
  puts "Class number #{i} : "+
    "#{tree_samples["#{i}"][:classifier].dependent_bayesian_classification(sample)}"
end

puts DataSets::get 'heart_disease'
