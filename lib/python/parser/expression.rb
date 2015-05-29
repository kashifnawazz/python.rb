require 'python/parser/combinator'
require 'python/parser/integer'
require 'python/parser/identifier'
require 'python/syntax'
require 'python/builtins'

module Python
  module Parser
    class ExpressionParser < Combinator

      parser :expression do
        conditional_expression
      end

      parser :conditional_expression do
        or_test >> proc{|true_exp|
          token_str("if") + or_test - token_str("else") >> proc{|cond|
            expression >> proc{|false_exp|
              ret(Syntax::Conditional.new(cond, true_exp, false_exp))
            }} | ret(true_exp)
          }
      end

      parser :or_test do # -> Expression
        orop = token_str("or") + ret(proc{|l, r| Syntax::Or.new(l, r)})
        binopl(and_test, orop)
      end

      parser :and_test do # -> Expression
        andop = token_str("and") + ret(proc{|l, r| Syntax::And.new(l, r)})
        binopl(not_test, andop)
      end

      parser :not_test do # -> Expression
        token_str("not") + not_test >> proc{|exp|
          ret(Syntax::Not.new(exp))
        } | comparison
      end

      parser :comparison do # -> Expression
        a_expr >> proc{|head|
          many(comp_operator >> proc{|op| a_expr >> proc{|exp| ret([op, exp])}}) >> proc{|tail|
            if tail.length == 0
              ret(head)
            else
              exps = [head] + tail.map{|op, exp| exp}
              ops = tail.map{|op, exp| op}
              comps = exps.each_cons(2).zip(ops).map{|p, op| Syntax::BinaryOp.new(op, p[0], p[1])}
              ret(comps.inject{|l, r| Syntax::And.new(l, r)})
            end
          }
        }
      end

      parser :comp_operator do # -> Symbol
        token_str("==") + ret("__eq__") |
        token_str(">=") + ret("__ge__") |
        token_str("<=") + ret("__le__") |
        token_str("<")  + ret("__lt__") |
        token_str(">")  + ret("__gt__") |
        token_str("!=") + ret("__ne__")
      end

      parser :a_expr do # -> Expression
        addop = token_str("+") + ret(lambda{|l, r| Syntax::BinaryOp.new("__add__", l, r)})
        subop = token_str("-") + ret(lambda{|l, r| Syntax::BinaryOp.new("__sub__", l, r)})
        binopl(m_expr, addop | subop)
      end

      parser :m_expr do # -> Expression
        mulop = token_str("*") + ret(proc{|l, r| Syntax::BinaryOp.new("__mul__", l, r)})
        fdivop = token_str("//") + ret(proc{|l, r| Syntax::BinaryOp.new("__floordiv__", l, r)})
        binopl(u_expr, mulop | fdivop)
      end

      parser :u_expr do # -> Expression
        posop = token_str("+") + ret("__pos__")
        negop = token_str("-") + ret("__neg__")
        (posop | negop) >> proc{|op_name|
          u_expr >> proc{|exp|
            ret(Syntax::UnaryOp.new(op_name, exp))
          }} | atom
      end

      parser :atom do
         identifier | integerliteral | parenth_form
      end

      parser :identifier do
        IdentifierParser.identifier >> proc{|ident| ret(Syntax::RefIdentifier.new(ident))}
      end

      parser :integerliteral do
        IntegerParser.integer >> proc{|n| ret(Syntax::LiteralObject.new(Builtins::Int.make_instance(n)))}
      end

      parser :parenth_form do
        token_str("(") + expression - token_str(")")
      end
    end
  end
end
