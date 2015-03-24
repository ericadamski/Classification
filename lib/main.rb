#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__))
require 'binarytree'
require 'binarytreedrawer'
require 'web_draw_binary_tree_controller'
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
  Classify.new samples["#{i}"][:samples]
end

#generate random tree, with random variables, train on 2000 samples create fully
#connected graph, do MST, estimate the original probabilities

##puts RandomDependencyTree.new
