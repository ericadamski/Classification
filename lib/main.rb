#!/usr/bin/env ruby
$: << File.expand_path(File.dirname(__FILE__))
require 'binarytree'
require 'binarytreedrawer'
require 'web_draw_binary_tree_controller'
require 'random_dependency_tree'

classes = ['OR', 'AND', 'XOR', "NAND"]

def get_true_false (val)
  (val == 0) ? true : false
end

def get_probability (_class)
  pr = lambda { |a, b| puts "a : #{a}, b : #{b}"}

  case _class
    when 'OR'
      pr = lambda { |a, b|
        _a = get_true_false a
        _b = get_true_false b
        return (_a or _b)
      }
    when 'AND'
      pr = lambda { |a, b|
        _a = get_true_false a
        _b = get_true_false b
        return (_a and _b)
      }
    when 'XOR'
      pr = lambda { |a, b|
        _a = get_true_false a
        _b = get_true_false b
        return (_a ^ _b)
      }
    when 'NAND'
      pr = lambda { |a, b|
        _a = get_true_false a
        _b = get_true_false b
        return (not (_a and _b))
      }
  end

  return pr
end

puts RandomDependencyTree.new.features
