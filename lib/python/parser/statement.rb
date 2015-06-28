require 'python/parser/combinator'
require 'python/syntax'
require 'python/parser/identifier'

module Python
  module Parser
    class StatementParser < Combinator

      NEWLINE = token_str("\n")
      INDENT = token_str("$I")
      DEDENT = token_str("$D")

      parser :file_input do # -> StatementList
        many(NEWLINE | statement) >> proc{|stmts|
          ret(Syntax::StatementList.new(stmts.select{|stmt| stmt.is_a?(Syntax::Statement)}))
        }
      end

      parser :suite do # -> StatementList
        stmt_list - NEWLINE | NEWLINE + INDENT + many1(statement) - DEDENT >> proc{|stmts|
          ret(Syntax::StatementList.new(stmts))
        }
      end

      parser :statement do # -> Statement
        compound_stmt | stmt_list - NEWLINE
      end

      parser :compound_stmt do # -> Statement
        classdef | funcdef
      end

      parser :funcdef do # -> Statement
        token_str("def") + IdentifierParser.identifier - token_str("(") >> proc{|funcname|
          separator_allow_empty(IdentifierParser.identifier, ",") - token_str(")") - token_str(":") >> proc{|params|
            suite >> proc{|stmt|
              ret(Syntax::Def.new(funcname, stmt, params))
            }}}
      end

      parser :classdef do # -> Statement
        token_str("class") + IdentifierParser.identifier >> proc{|classname|
          ((token_str("(") + separator(ExpressionParser.expression, ",") - token_str(")")) | ret([])) - token_str(":") >> proc{|base_exps|
            suite >> proc{|stmt|
              ret(Syntax::ClassDef.new(classname, stmt, base_exps))
            }}}
      end

      parser :stmt_list do # -> StatementList
        separator(simple_stmt, ";") - (token_str(";") | ret(nil)) >> proc{|stmts|
          ret(Syntax::StatementList.new(stmts))
        }
      end

      parser :simple_stmt do # -> Statement
        assignment_stmt | return_stmt | expression_stmt
      end

      parser :assignment_stmt do # -> Statement
        ((IdentifierParser.identifier - token_str("=")) | (ExpressionParser::primary - token_str("="))) >> proc{|target|
          ExpressionParser.expression >> proc{|exp|
            case target
            when String
              ret(Syntax::AssignIdentifier.new(target, exp))
            when Syntax::AttrRef
              ret(Syntax::AssignAttr.new(target.receiver, target.attrname, exp))
            else
              p target
              failure
            end
          }}
      end

      parser :return_stmt do # -> Statement
        token_str("return") + (ExpressionParser.expression | ret(nil)) >> proc{|exp|
            ret(Syntax::Return.new(exp))
        }
      end

      parser :expression_stmt do
        ExpressionParser.expression
      end

    end
  end
end
