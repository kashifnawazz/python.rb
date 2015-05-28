require 'python/pyobject'

module Python
  class Expression

    def eval
      PyObject.new
    end

    def ==(other)
      self.to_a == other.to_a
    end

    class BinaryOp < Expression
      def initialize(op_name, left, right)
        @op_name, @left, @right = op_name, left, right
      end

      def to_a
        [self.class, @op_name, @left, @right]
      end

      def eval
        left, right = @left.eval, @right.eval
        left.call_special_method(@op_name, right)
      end
    end

    class UnaryOp < Expression
      def initialize(op_name, exp)
        @op_name, @exp = op_name, exp
      end

      def to_a
        [self.class, @op_name, @exp]
      end

      def eval
        @exp.eval.call_special_method(@op_name)
      end
    end

    class LiteralObject < Expression
      def initialize(pyobject)
        @pyobject = pyobject
      end

      def to_a
        [self.class, @pyobject]
      end

      def eval
        @pyobject
      end
    end
  end
end
