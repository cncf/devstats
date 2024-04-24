#!/usr/bin/env ruby

require 'pry'

if ARGV.length < 2
  puts "you need to specify file-name and metric to search"
  return
end
fn = ARGV[0]
metric = ARGV[1]
top = ENV['TOP']
top = top.to_i unless top.nil?

data = []
File.readlines(fn).each_with_index do |line, i|
  m = line.match /.*#{metric}=(\d+i(\.\d+)?)\.\.(\d+(\.\d+)?).*/
  if m
    t = m[2].to_f - m[1].to_f
    next if t == 0.0
    ti = m[2].to_i - m[1].to_i
    next if ti == 0 || t < 1.0
    s = m[1] + ".." + m[2]
    data << [t, s, i, line]
    next
  end
  m = line.match /.*#{metric}=(\d+(\.\d+)?).*/
  if m
    t = m[1].to_f
    next if t == 0.0
    ti = m[1].to_i
    next if ti == 0 || t < 1.0
    s = m[1]
    data << [t, s, i, line]
    next
  end
end

data = data.sort_by { |row| -row[0] }
data.each_with_index do |row, i|
  break if top > 0 and i > top
  puts "#{metric}: ##{row[2]}) #{row[0]}: #{row[3]}"
end