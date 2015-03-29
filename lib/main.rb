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
samples = [] # classification vector and samples

for i in 0..3 do
  samples.push ({ :vector => classes[i],
    :samples => generator.generate_samples(classes[i].probabilities) })
end

independent_classifyer = Classify.new samples

# classify using independent bayesian classification=

puts independent_classifyer.get_accuracy

#generate random tree, with random variables, train on 2000 samples
trees = []

4.times do
  trees.push Tree.new
end

tree_samples = []

for i in 0..3 do
  tree_samples.push ({ :tree => trees[i],
    :samples => generator.generate_samples_from_tree(trees[i].features) })
end

dependent_classifyer = Classify.new tree_samples

puts dependent_classifyer.get_accuracy true

#puts DataSets::get 'heart_disease'
