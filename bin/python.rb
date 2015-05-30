#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'python'

if ARGV[0]
  File.open(ARGV[0], "r") do |file|
    Python::FileInterpreter.new(file.read).execute
  end
else
  repl = Python::REPL.new(STDOUT)
  repl.start
  while input = STDIN.gets
    repl.read_eval_print(input)
    repl.prompt
  end
end
