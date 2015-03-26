#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__))
require 'tree'
require 'random_vector'
require 'sample'
require 'classify'

generator = Sample.new

classes = []
#generate 4 random vectors, each dimension 10
4.times do
  classes.push RandomVector.new
end

#generate 2000 samples
samples = Hash.new # classification vector and samples

for i in 0..3 do
  samples["#{i}"] = { :vector => classes[i],
    :samples => generator.generate_samples(classes[i].probabilities) }
end

# classify using independence, bayesian classification
for i in 0..3 do
  class1 = Classify.new samples["#{i}"][:samples]
  #puts "Real : #{classes[i].probabilities}"
  #puts "Clas : #{class1.classifing_vector}"
  #puts class1.testing_data[0].sample
  #puts class1.independent_bayesian_classification(class1.testing_data[0].sample)
end

#generate random tree, with random variables, train on 2000 samples
trees = []

4.times do
  trees.push Tree.new
end

tree_samples = Hash.new

for i in 0..3 do
  tree_samples["#{i}"] = { :tree => trees[i],
    :samples => generator.generate_samples_from_tree(trees[i].features) }
end

trees[0].output '/../output/proper.png'
(Classify.new tree_samples["0"][:samples]).infer_dependence_tree
