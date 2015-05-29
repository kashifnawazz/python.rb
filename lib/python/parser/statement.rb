require 'python/parser/combinator'
require 'python/syntax'
require 'python/parser/identifier'

module Python
  module Parser
    class StatementParser < Combinator

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
