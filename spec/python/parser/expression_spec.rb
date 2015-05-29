require 'spec_helper'

module Python
  module Parser
    describe ExpressionParser do
      describe "#parse" do
        def BOP(name, l, r)
          Expression::BinaryOp.new(name, l, r)
        end

        def UOP(name, e)
          Expression::UnaryOp.new(name, e)
        end

        def LO(n)
          Expression::LiteralObject.new(Builtins::Int.make_instance(n))
        end

        it "parse numerical expression" do
          ast = ExpressionParser.expression.parse("-(1+10)*+(100//1000)").parsed
          expect(ast) == BOP("__mul__",
                             UOP("__neg__", BOP("__add__", LO(1), LO(10))),
                             UOP("__pos__", BOP("__floordiv__", LO(100), LO(1000))))
        end
      end
    end
  end
end
