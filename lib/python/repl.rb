require 'python/parser/statement'
require 'python/environment'

module Python
  class REPL
    ParsingError = Class.new(RuntimeError)

    def initialize(output)
      @output = output
      @env = Environment.new
    end

    def start
      prompt
    end

    def read_eval_print(code)
      print(eval(read(code)))
    end

    def read(code)
      parser = Parser::StatementParser.stmt_list
      result = parser.parse(code)
      if result.is_a?(Parser::Succeeded) && result.rest.chomp == ""
        result.parsed
      else
        raise ParsingError.new
      end
    end

    def eval(exp)
      exp.eval(@env)
    end

    def print(obj)
      if obj == nil
        @output.print ""
      else
        @output.puts obj.inspect
      end
    end

    def prompt
      @output.print "python.rb> "
    end
  end
end
