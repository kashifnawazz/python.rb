require 'python/parser'

module Python
  class REPL
    def initialize(output)
      @output = output
    end

    def start
      print_console
    end

    def read_eval_print(code)
      print(eval(read(code)))
    end

    def read(code)
      parser = Parser::ExpressionParser.new
      parser.parse(code)
    end

    def eval(exp)
      exp.eval
    end

    def print(obj)
      @output.puts obj.entity.to_s
    end

    def print_console
      @output.print "python.rb> "
    end
  end
end
