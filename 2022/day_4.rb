#!/usr/bin/ruby
require 'pp'

def process_assignments(file)
  assignments = {}
  fully_contained_count = 0
  overlap_count = 0

  file.each_line.with_index(1) do |line, assignment_count|
    line.strip!

    # Build pairs of upper and lower bounds
    pairs = line.split(',').map { |assignment| assignment.split('-').map { |bound| bound.to_i} }

    # Generate pairs into sequences
    pairs = pairs.map { |bounds| (bounds[0]..bounds[1]).to_a }

    # Test for assignment overlap and containment
    fully_contained = ((pairs[0] - pairs[1]).empty? or (pairs[1] - pairs[0]).empty?) ? true : false
    overlaping = !(pairs[0] & pairs[1]).empty?

    assignments[assignment_count] = {
      pairs: pairs,
      fully_contained: fully_contained,
      overlaping: overlaping
    }

    fully_contained_count += 1 if fully_contained
    overlap_count += 1 if overlaping or fully_contained
  end
  #PP.pp(assignments, out=$>, width=500)

  return [fully_contained_count, overlap_count]
end

file = File.open(ARGV.first)

return_vals = process_assignments(file)
puts "Total number of fully contained assignments: " + return_vals[0].to_s
puts "Total number of overlaping assignments: " + return_vals[1].to_s