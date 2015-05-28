require 'python/expression'

module Python
  module Parser
    class ExpressionParser
      def parse(str)
        stack = []
        expression(stack, to_tokens(str))
        stack.pop
      end

      def to_tokens(str)
        str.gsub(/\/\//, " // ").gsub(/([\(\)\+\-\*])/, " \\1 ").split
      end

      def apply_binary_op(stack, op_name)
        right, left = stack.pop, stack.pop
        stack.push(Expression::BinaryOp.new(op_name, left, right))
      end

      def expression(stack, tokens)
        term(stack, tokens)
        while tokens.first == "+" || tokens.first == "-"
          op_name = tokens.first == "+" ? "__add__" : "__sub__"
          tokens.shift
          term(stack, tokens)
          apply_binary_op(stack, op_name)
        end
      end

      def term(stack, tokens)
        factor(stack, tokens)
        while tokens.first == "*" || tokens.first == "//"
          op_name = tokens.first == "*" ? "__mul__" : "__floordiv__"
          tokens.shift
          factor(stack, tokens)
          apply_binary_op(stack, op_name)
        end
      end

      def factor(stack, tokens)
        next_token = tokens.first
        tokens.shift
        case next_token
        when "+", "-"
          factor(stack, tokens)
          op_name = next_token == "+" ? "__pos__" : "__neg__"
          stack.push(Expression::UnaryOp.new(op_name, stack.pop))
        when "("
          expression(stack, tokens)
          tokens.shift
        else
          stack.push(Expression::LiteralObject.new(PyObject.new(:entity => next_token.to_i)))
        end
      end
    end
  end
end
