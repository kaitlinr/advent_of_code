#!/usr/bin/ruby
require 'pp'

def build_priority
  h = {}
  ('a'..'z').each_with_index{|w, i| h[w] = i + 1 } 

  h2 = {}
  ('A'..'Z').each_with_index{|w, i| h2[w] = i + 27 } 

  h.merge(h2)
end

PRIORITY_MAP = build_priority

# Using a hashmap is unnecesary here.
# However, I liked the idea of keeping track of which elf has
# which items just incase the second part of the question
# needed this info.
def process_rucksacks(file)
  rucksacks = {}

  file.each_line.with_index do |line, sack_count|
    line.strip!
    a = line.split("")
    left, right = a.each_slice((a.size/2.0).round).to_a
    common_element = left.intersection(right).first

    rucksacks[sack_count] = {
      items: left + right,
      common_element: common_element,
      priority: PRIORITY_MAP[common_element]
    }
  end

  return rucksacks
end

def inventory_by_group(sacks)
  sack_by_group = {}
  group_count = 0

  sack_list = []
  sacks.each do |_k, val|
     sack_list.push(val[:items])

     if sack_list.size == 3
       common_elements = sack_list[0].intersection(sack_list[1], sack_list[2])
       common_element = common_elements.first
       sack_by_group[group_count] = {
         badge: common_element,
         priority: PRIORITY_MAP[common_element]
       }
       
       sack_list = []
       group_count += 1
     end
  end
  sack_by_group
end

def priority_score(inventory)
  inventory.values.sum { |h| h[:priority] }
end

priority_map = build_priority

file = File.open(ARGV.first)

inventory = process_rucksacks(file)
puts "Total item priority score: " + priority_score(inventory).to_s

group_inventory = inventory_by_group(inventory)
puts "Total badge priority score: " + priority_score(group_inventory).to_s