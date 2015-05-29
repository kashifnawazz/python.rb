module Python
  module Syntax
    module SyntaxUtil
      def py_runtime_error(*attrs)
        min_argc = attrs.take_while{|attr| attr.is_a?(Symbol)}.count
        max_argc = attrs.flatten.count
        cls = Class.new(RuntimeError)
        cls.send(:define_method, :initialize) do |*args|
          if min_argc <= args.length && args.length <= max_argc
            attrs.flatten.zip(args).each do |name, val|
              instance_variable_set("@#{name}".to_sym, val)
            end
          else
            raise "Argument error: failed to make instance of #{cls.name}."
          end
        end
        attrs.flatten.each do |name|
          cls.send(:attr_reader, name)
        end
        return cls
      end

      def stmt(*attrs, &eval)
        define_element_type(Statement, *attrs, &eval)
      end

      def exp(*attrs, &eval)
        define_element_type(Expression, *attrs, &eval)
      end

      def define_element_type(base, *attrs, &eval_proc)
        cls = Class.new(base)
        define_initialize_method(cls, *attrs)
        define_eval_method(cls, &eval_proc)
        define_eq_method(cls, *attrs)
        attrs.flatten.each {|name| cls.send(:attr_reader, name) }
        return cls
      end

      def define_initialize_method(cls, *attrs)
        min_argc = attrs.take_while{|attr| attr.is_a?(Symbol)}.count
        max_argc = attrs.flatten.count
        cls.send(:define_method, :initialize) do |*args|
          unless min_argc <= args.length && args.length <= max_argc
            raise "Argument error: failed to make instance of #{cls.name}." +
                  "expected: #{attrs}, actual: #{args}"
          end
          attrs.flatten.zip(args).each do |name, val|
            instance_variable_set("@#{name}".to_sym, val)
          end
        end
      end

      def define_eval_method(cls, &eval_proc)
        cls.send(:define_method, :eval) do |env|
          instance_exec(env, &eval_proc)
        end
      end

      def define_eq_method(cls, *attrs)
        cls.send(:define_method, :==) do |other|
          self.class == other.class && attrs.all?{|vname|
            ivname = "@#{vname}".to_sym
            self.instance_variable_get(ivname) == other.instance_variable_get(ivname)
          }
        end
      end
    end
  end
end
