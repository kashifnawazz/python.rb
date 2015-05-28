require 'python/parser/expression'

module Python
  class REPL
    ParsingError = Class.new(RuntimeError)

    def initialize(output)
      @output = output
    end

    def start
      prompt
    end

    def read_eval_print(code)
      print(eval(read(code)))
    end

    def read(code)
      parser = Parser::ExpressionParser.expression
      case result = parser.parse(code)
      when Parser::Succeeded
        result.parsed
      when Parser::Failed
        raise ParsingError.new
      end
    end

    def eval(exp)
      exp.eval
    end

    def print(obj)
      @output.puts obj.entity.to_s
    end

    def prompt
      @output.print "python.rb> "
    end
  end
end
