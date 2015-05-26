#!/usr/bin/env ruby
$LOAD_PATH << File.expand_path('../../lib', __FILE__)
require 'python'

repl = Python::REPL.new(STDOUT)
repl.start
