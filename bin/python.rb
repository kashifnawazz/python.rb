#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'python'

repl = Python::REPL.new(STDOUT)
repl.start
while input = STDIN.gets
  repl.read_eval_print(input)
  repl.prompt
end
