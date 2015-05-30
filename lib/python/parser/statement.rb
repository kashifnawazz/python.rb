require 'python/parser/combinator'
require 'python/syntax'
require 'python/parser/identifier'

module Python
  module Parser
    class StatementParser < Combinator

      NEWLINE = token_str("\n")
      INDENT = token_str("$I")
      DEDENT = token_str("$D")

      parser :file_input do
        many(NEWLINE | statement) >> proc{|stmts|
          ret(stmts.select{|stmt| stmt.is_a?(Syntax::Statement)})
        }
      end

      parser :statement do
        assignment_stmt | ExpressionParser.expression
      end

      parser :assignment_stmt do
        IdentifierParser.identifier - token_str("=") >> proc{|ident|
          ExpressionParser.expression >> proc{|exp|
            ret(Syntax::AssignIdentifier.new(ident, exp))
          }}
      end
    end
  end
end
