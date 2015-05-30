require 'python/parser/statement'
require 'python/parser/indent_converter'
require 'python/environment'

module Python
  class FileInterpreter
    ParsingError = Class.new(RuntimeError)

    def initialize(code)
      @code = code
    end

    def parse
      parser = Parser::StatementParser.file_input
      result = parser.parse(IndentConverter.new.convert(@code))
      if result.is_a?(Parser::Succeeded) && result.rest == ""
        result.parsed
      else
        raise ParsingError.new
      end
    end

    def execute
      stmts = parse()
      env = Environment.new
      stmts.each do |stmt|
        stmt.eval(env)
      end
    end
  end
end
