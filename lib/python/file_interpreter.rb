require 'python/parser/statement'
require 'python/parser/indent_converter'
require 'python/environment'

module Python
  class FileInterpreter
    ParsingError = Class.new(RuntimeError)

    def initialize(code, bind={})
      @code = code
      @bind = bind
    end

    def parse
      parser = Parser::StatementParser.file_input
      result = parser.parse(Parser::IndentConverter.new.convert(@code))

      if result.is_a?(Parser::Succeeded) && result.rest == ""
        result.parsed
      else
        raise ParsingError.new
      end
    end

    def execute
      parse().eval(Environment.new(@bind))
    end
  end
end
