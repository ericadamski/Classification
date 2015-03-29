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
