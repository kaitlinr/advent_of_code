#!/usr/bin/ruby
require 'pp'

def process_lines(file)
  stacks = {}
  direction_lines = []
  read_directions = false

  while (line = file.gets)
    if line =~ /^\n$/
      read_directions = true
      next 
    end

    if read_directions
        direction_lines << line
    else
        next if line.include?("1")
        line.scan(/.{1,4}/).each_with_index do |crate, stack_id|
            stacks[stack_id + 1] ? stacks[stack_id + 1] << crate : stacks[stack_id + 1] = [crate]
        end
    end
  end

  [stacks, direction_lines]
end

def clean_stacks(stacks)
    stacks.each do |stack_id, stack|
        stacks[stack_id] = stack.reverse.uniq - ["    ", "   "]
    end
end

def move_crates(stacks, moves)
  stacks_one_at_time = Marshal.load(Marshal.dump(stacks))

  moves.each do |move|
    move = move.tap{|s| s.slice!("move")}.split("from")
    crate_count = move[0].strip.to_i 

    # More logic than necessary, but helpful for me to have meaninful variable names
    modified_stacks = move[1].split("to")
    from_stack = modified_stacks[0].strip.to_i
    to_stack = modified_stacks[1].strip.to_i

    counter = crate_count
    while counter > 0
        stacks_one_at_time[to_stack] << stacks_one_at_time[from_stack].pop
        counter -= 1
    end

    stacks[to_stack] << stacks[from_stack].pop(crate_count)
    stacks[to_stack].flatten!
  end
  [stacks_one_at_time, stacks]
end

def top_of_stacks(stacks)
    top_of_stacks = ""
    stacks.each do |_stack_id, stack|
        next if stack.size == 0 or stack.last.nil?
        top_of_stacks += stack.last.tr('[] ', '')
    end
    top_of_stacks
end

file = File.open(ARGV.first)

lines = process_lines(file)
file.close

final_stacks = move_crates(clean_stacks(lines[0]), lines[1])

puts "The top of stacks when moving one crate at a time: " + top_of_stacks(final_stacks[0])
puts "The top of stacks when moving multiple crates at a time: " + top_of_stacks(final_stacks[1])