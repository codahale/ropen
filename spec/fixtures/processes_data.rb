#!/usr/bin/env ruby
STDIN.each_line do |line|
  STDERR.puts "Input: #{line.inspect}"
  STDOUT.puts line.chomp.upcase
end
exit(2)