require 'python/expression'

module Python
  class Parser
    class ExpressionParser
      def parse(str)
        stack = []
        exp(stack, to_tokens(str))
        stack.pop
      end

      def to_tokens(str)
        str.gsub(/\/\//, " // ").gsub(/([\(\)\+\-\*])/, " \\1 ").split
      end

      def exp(stack, tokens)
        stack.push(Expression.new)
      end

      def term(stack, tokens)

      end

      def fact(stack, tokens)

      end
    end
  end
end
