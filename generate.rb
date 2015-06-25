#!/usr/bin/env ruby

require 'json'
require 'open-uri'

compact = !!ARGV.delete("--compact")
file_path = ARGV[0] or abort "error: file path is not given"

version = nil
values = []
last = {}

open(file_path) do |f|
  text = f.read
  text =~ /\A# EastAsianWidth-(.+?)\.txt/
  version = $1
  text.scan(/^([0-9A-Z]+)(?:\.\.([0-9A-Z]+))?;([A-Za-z]+)/) do |b, e, prop|
    last_end = last[:code_point_end] || last[:code_point]
    if compact && last[:property] == prop && last_end && Integer(last_end, 16) + 1 == Integer(b, 16)
      values.pop
      e = b unless e
      b = last[:code_point_begin] || last[:code_point]
    end
    if e
      values << (last = {:code_point_begin => b, :code_point_end => e, :property => prop})
    else
      values << (last = {:code_point => b, :property => prop})
    end
  end
end

puts JSON.pretty_generate({:version => version, :values => values})
