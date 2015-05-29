require 'python/parser/combinator'
require 'python/parser/integer'
require 'python/expression'
require 'python/builtins'

module Python
  module Parser
    class ExpressionParser < Combinator
      E = Expression

      parser :expression do
        a_expr
      end

      parser :a_expr do # -> Expression
        addop = token_str("+") + ret(lambda{|l, r| E::BinaryOp.new("__add__", l, r)})
        subop = token_str("-") + ret(lambda{|l, r| E::BinaryOp.new("__sub__", l, r)})
        binopl(m_expr, addop | subop)
      end

      parser :m_expr do # -> Expression
        mulop = token_str("*") + ret(proc{|l, r| E::BinaryOp.new("__mul__", l, r)})
        fdivop = token_str("//") + ret(proc{|l, r| E::BinaryOp.new("__floordiv__", l, r)})
        binopl(u_expr, mulop | fdivop)
      end

      parser :u_expr do # -> Expression
        posop = token_str("+") + ret("__pos__")
        negop = token_str("-") + ret("__neg__")
        (posop | negop) >> proc{|op_name|
          u_expr >> proc{|exp|
            ret(E::UnaryOp.new(op_name, exp))
          }} | atom
      end

      parser :atom do
         integerliteral | parenth_form
      end

      parser :integerliteral do
        IntegerParser.integer >> proc{|n| ret(E::LiteralObject.new(Builtins::Int.make_instance(n)))}
      end

      parser :parenth_form do
        token_str("(") + expression - token_str(")")
      end
    end
  end
end
