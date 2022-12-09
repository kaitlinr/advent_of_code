#!/usr/bin/ruby
require 'pp'

# Oh so ugly - ran out of time to clean this up.  Ewwww....
# There's a lot of duplication of logic happening here.  *sigh*

class TreeGrid 
    attr_accessor :grid, :total_visible, :best_scenic_score

    def initialize
        @grid = []
        @total_visible = 0
        @best_scenic_score = 0
    end

    def add_new_row(row)
        @grid << row
    end
end

class Tree
    attr_accessor :height, :visible, :scenic_score

    def initialize(height)
        @height = height
        @visible = false
        @scenic_score = 0
    end
end

def build_grid(file)
    grid = TreeGrid.new

    while (line = file.gets)
        line.strip!

        grid.add_new_row(line.chars.map { |c| Tree.new(c.to_i) })
    end

    grid
end

def is_visible(tree_grid, tree, row_idx, col_idx)
    new_tree = tree_grid.grid[row_idx][col_idx]
    new_tree.height < tree.height ? true : false
end

def compare_visible(tree_grid, row_idx, col_idx)
    tree = tree_grid.grid[row_idx][col_idx]
    visible_from_edge = false 

    # Check left
    tmp_idx = col_idx - 1
    while tmp_idx >= 0
        visible_from_edge = is_visible(tree_grid, tree, row_idx, tmp_idx)
        break unless visible_from_edge
        tmp_idx -= 1
    end
    return tree.visible = true if visible_from_edge

    # Check up
    tmp_idx = row_idx - 1
    while tmp_idx >= 0
        visible_from_edge = is_visible(tree_grid, tree, tmp_idx, col_idx)
        break unless visible_from_edge
        tmp_idx -= 1
    end
    return tree.visible = true if visible_from_edge

    # Check right
    tmp_idx = col_idx + 1
    while tmp_idx < tree_grid.grid[0].size
        visible_from_edge = is_visible(tree_grid, tree, row_idx, tmp_idx)
        break unless visible_from_edge
        tmp_idx += 1
    end
    return tree.visible = true if visible_from_edge

    # Check down 
    tmp_idx = row_idx + 1
    while tmp_idx < tree_grid.grid.size
        visible_from_edge = is_visible(tree_grid, tree, tmp_idx, col_idx)
        break unless visible_from_edge
        tmp_idx += 1
    end
    tree.visible = true if visible_from_edge
end

# This is horrible - ran out of time
def set_scenic_score(tree_grid, row_idx, col_idx)
    tree = tree_grid.grid[row_idx][col_idx]
    viewing_distances = []
    view_count = 0

    # Check left
    tmp_idx = col_idx - 1
    while tmp_idx >= 0
        break if row_idx == 0    

        new_tree = tree_grid.grid[row_idx][tmp_idx]
        view_count += 1
        break if new_tree.height >= tree.height

        tmp_idx -= 1
    end
    viewing_distances << view_count
    view_count = 0

    # Check up
    tmp_idx = row_idx - 1
    while tmp_idx >= 0
        break if col_idx == 0

        new_tree = tree_grid.grid[tmp_idx][col_idx]
        view_count += 1
        break if new_tree.height >= tree.height

        tmp_idx -= 1
    end
    viewing_distances << view_count
    view_count = 0

    # Check right
    tmp_idx = col_idx + 1
    while tmp_idx < tree_grid.grid[0].size
        break if row_idx == tree_grid.grid[0].size - 1

        new_tree = tree_grid.grid[row_idx][tmp_idx]
        view_count += 1
        break if new_tree.height >= tree.height

        tmp_idx += 1
    end
    viewing_distances << view_count
    view_count = 0

    # Check down 
    tmp_idx = row_idx + 1
    while tmp_idx < tree_grid.grid.size
        break if col_idx == tree_grid.grid[0].size - 1

        new_tree = tree_grid.grid[tmp_idx][col_idx]
        view_count += 1
        break if new_tree.height >= tree.height

        tmp_idx += 1
    end
    viewing_distances << view_count

    viewing_distances.reject!(&:zero?)
    tree.scenic_score = viewing_distances.inject(:*) unless viewing_distances.empty?
end

def find_visible(tree_grid)
    tree_grid.grid.each_with_index do |row, row_idx|
        row.each_with_index do |elm, col_idx|
            set_scenic_score(tree_grid, row_idx, col_idx)

            if row_idx == 0 or col_idx == 0 or row_idx == tree_grid.grid.size - 1 or col_idx == row.size - 1
                tree_grid.grid[row_idx][col_idx].visible = true
                next
            end
            compare_visible(tree_grid, row_idx, col_idx) 
        end
    end
end

def count_visible(tree_grid)
    tree_grid.grid.each_with_index do |row, row_idx|
        row.each_with_index do |elm, col_idx|
            tree_grid.total_visible += 1 if elm.visible
        end
    end
end

def find_heighest_scenic_score(tree_grid)
    highest_score = tree_grid.grid[0][0]

    tree_grid.grid.each_with_index do |row, row_idx|
        row.each_with_index do |elm, col_idx|
            highest_score = elm if elm.scenic_score > highest_score.scenic_score 
        end
    end

    tree_grid.best_scenic_score = highest_score.scenic_score
end

file = File.open(ARGV.first)
grid = build_grid(file)
file.close

find_visible(grid)
count_visible(grid)
find_heighest_scenic_score(grid)

puts "Total visible trees in grid is: #{grid.total_visible}"
puts "Best possible scenic score is: #{grid.best_scenic_score}"