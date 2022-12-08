#!/usr/bin/ruby
require 'pp'

class DDirectory
    include Comparable
    attr_accessor :name, :parent, :children, :size

    def initialize(name, parent)
        @name = name
        @parent = parent 
        @children = {} 
        @size = 0
    end

    def <=>(other)
        size <=> other.size
    end
end

class FFile
    attr_accessor :name, :size

    def initialize(name, size)
        @name = name
        @size = size
    end
end

def build_filesystem(file)
    top_node = DDirectory.new("/", nil)
    curr_node = top_node

    while (line = file.gets)
        line.strip!
        next if line.include?("$ ls")

        if line.include?("$ cd")
            new_dir = line.split("cd ").last
            if new_dir == "/"
                next
            elsif new_dir == ".."
                curr_node = curr_node.parent
            elsif curr_node.children[new_dir].nil?
                curr_node.children[new_dir] = DDirectory.new(new_dir, curr_node)
                curr_node = curr_node.children[new_dir]
            else
                curr_node = curr_node.children[new_dir]
            end
        else
            vals = line.split(" ")
            if vals.include?("dir")
                curr_node.children[vals.last] = DDirectory.new(vals.last, curr_node)
            else
                curr_node.children[vals.last] = FFile.new(vals.last, vals.first.to_i)
            end
        end
    end
    top_node
end

def update_dir_size(node)
    if node.is_a? FFile
        #puts "\t\t\tReturning FILE node size: " + node.size.to_s
        return node.size
    end
    
    if node.is_a? DDirectory and node.children.empty?
        #puts "\t\t\tReturning DIR node size: " + node.size.to_s
        return node.size
    end

    # puts "\n\tProcessing children for node [#{node.name}]"
    sum = node.size
    node.children.each do |_k, v|
        # puts "\t\tNode size in the for loop for node [#{v.name}] is #{v.size.to_s}"
        size = update_dir_size(v)
        # puts "\t\tSize returned is: " + size.to_s
        sum += size
    end

    # puts "\tSum for node [#{node.name}] is #{sum.to_s}"
    node.size = sum
    sum
end

def find_total_size(node)
    return 0 if node.is_a? FFile

    sum = 0

    if node.is_a? DDirectory and node.children.empty?
        return node.size <= 100000 ? node.size : 0
    end

    sum += node.size <= 100000 ? node.size : 0

    node.children.each do |_k, v|
        sum += find_total_size(v)
    end

    sum
end

def find_dir_to_delete(node, additional_space_needed)
    return nil if node.is_a? FFile

    candidates = []

    if node.is_a? DDirectory and node.children.empty?
        return node.size >= additional_space_needed ? node : nil
    end

    candidates << node if node.size >= additional_space_needed

    node.children.each do |_k, v|
        possible_dir = find_dir_to_delete(v, additional_space_needed)
        candidates << possible_dir if !possible_dir.nil?
    end

    candidates.compact.sort.first
end

file = File.open(ARGV.first)
fs_tree = build_filesystem(file)
file.close

update_dir_size(fs_tree)

puts "Total size of all directories < 100000 is #{find_total_size(fs_tree)}"

total_fs_space = 70000000
free_space_needed = 30000000
current_free_space = total_fs_space - fs_tree.size
additional_space_needed = free_space_needed - current_free_space

puts "Current free space is #{current_free_space}, we need #{additional_space_needed}"

dir_to_delete = find_dir_to_delete(fs_tree, additional_space_needed)
puts "Remove directory #{dir_to_delete.name} with size #{dir_to_delete.size}"
