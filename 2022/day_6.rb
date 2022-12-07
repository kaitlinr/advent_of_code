#!/usr/bin/ruby
require 'pp'

def find_start_of_packet(line)
    marker = ""
    line.chars.each_with_index do |char, idx|
        return idx if marker.size == 4

        marker = marker.partition(char).last if marker.include?(char)

        marker += char
    end
end

def find_start_of_message(line, start_of_packet)
    marker = ""
    line.chars.each_with_index do |char, idx|
        next if idx < start_of_packet - 4
        return idx if marker.size == 14

        marker = marker.partition(char).last if marker.include?(char)

        marker += char
    end
end

file = File.open(ARGV.first)

while (line = file.gets)
    start_of_packet = find_start_of_packet(line)
    puts "Start of packet is: " + start_of_packet.to_s

    puts "Start of message is: " + find_start_of_message(line, start_of_packet).to_s + "\n\n"
end

file.close