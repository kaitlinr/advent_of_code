#!/usr/bin/ruby

# Unknown if we'll need to know which elf is which
# Assign each elf a number and keep track of 
# inventories by elf
def process_inventory(file)
  inventories = {}
  elf_count = 0
     
  while (line = file.gets)
    line.strip!

    if line.empty? or elf_count == 0
        elf_count += 1
        inventories[elf_count] = {
            inventory: [],
            sum: 0
        } 
    else
        val = line.to_i
        inventories[elf_count][:inventory] << val
        inventories[elf_count][:sum] += val
    end
  end

  inventories.sort_by { |_key, hsh| hsh[:sum] }.to_h
end

def most_calories(list, count)
  list.to_a.last(count).to_h.values.sum { |h| h[:sum] }
end

file = File.open(ARGV.first)
inventory = process_inventory(file)

puts "Elf with the most calories has: " + most_calories(inventory, 1).to_s
puts "Top three elves with the most calories has: " + most_calories(inventory, 3).to_s