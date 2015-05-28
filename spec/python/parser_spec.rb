require 'spec_helper'

module Python
  module Parser
    describe ExpressionParser do
      describe "#to_tokens" do
        it "separate string into strings of token" do
          tokens = ExpressionParser.new.to_tokens("-(1+10)*+(100//1000)")
          expect(tokens).to eq(["-", "(", "1", "+", "10", ")", "*", "+", "(", "100", "//", "1000", ")"])
        end
      end

      describe "#apply_binary_op" do
        it "make Expression::BinaryOp" do
          bop = ExpressionParser.new.apply_binary_op([:x, :y], :op_name)
          expect(bop) == Expression::BinaryOp.new(:op_name, :x, :y)
        end
      end

      describe "#expression" do
        def BOP(name, l, r)
          Expression::BinaryOp.new(name, l, r)
        end

        def UOP(name, e)
          Expression::UnaryOp.new(name, e)
        end

        def LO(n)
          Expression::LiteralObject.new(PyObject.new(:entity => n))
        end

        it "parse numerical expression" do
          ast = ExpressionParser.new.parse("-(1+10)*+(100//1000)")
          expect(ast) == BOP("__mul__",
                             UOP("__neg__", BOP("__add__", LO(1), LO(10))),
                             UOP("__pos__", BOP("__floordiv__", LO(100), LO(1000))))
        end
      end
    end
  end
end
