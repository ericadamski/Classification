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
  samples.push ({ :type => i, :vector => classes[i],
    :samples => generator.generate_samples(classes[i].probabilities) })
end

independent_classifyer = Classify.new samples

#classify using independent bayesian classification=

puts independent_classifyer.get_accuracy

#generate random tree, with random variables, train on 2000 samples
trees = []

4.times do
  trees.push Tree.new
end

tree_samples = []

for i in 0..3 do
  tree_samples.push ({ :type => i, :tree => trees[i],
    :samples => generator.generate_samples_from_tree(trees[i].features) })
end

dependent_classifyer = Classify.new tree_samples

puts dependent_classifyer.get_accuracy true

iris_data_set  = DataSets::get 'iris'
wine_data_set  = DataSets::get 'wine'
heart_data_set = DataSets::get 'heart_disease'

heart_class_types = heart_data_set.map { |vec| vec.last }.uniq
iris_class_types  = iris_data_set.map  { |vec| vec.last }.uniq
wine_class_types  = wine_data_set.map  { |vec| vec.last }.uniq

hearts = []
wines  = []
iriss  = []

for type in heart_class_types do
  hearts.push ({ :type => type, :samples =>
    heart_data_set.select { |vec|
      vec.last == type }.map { |vec| vec.take vec.size - 1 }})
end

for type in wine_class_types do
  wines.push ({ :type => type, :samples =>
    wine_data_set.select { |vec|
      vec.last == type }.map { |vec| vec.drop 1 } })
end

for type in iris_class_types do
  iriss.push ({ :type => type, :samples =>
    iris_data_set.select { |vec|
      vec.last == type }.map { |vec| vec.take vec.size - 1 } })
end

iris_classifier  = Classify.new iriss
wine_classifier  = Classify.new wines
heart_classifier = Classify.new hearts

puts wine_classifier.get_accuracy true, wines[0][:samples].sample().size - 1
puts iris_classifier.get_accuracy true, iriss[0][:samples].sample().size - 1
puts heart_classifier.get_accuracy true, hearts[0][:samples].sample().size - 1

for i in 0..iris_class_types.size - 1
  iris_classifier.create_decision_tree iriss[i], iris_data_set
end

for i in 0..wine_class_types.size - 1
  wine_classifier.create_decision_tree wines[i], wine_data_set
end

for i in 0..heart_class_types.size - 1
  heart_classifier.create_decision_tree hearts[i], heart_data_set
end

puts wine_classifier.get_accuracy 'DT'
puts iris_classifier.get_accuracy 'DT'
puts heart_classifier.get_accuracy 'DT'
