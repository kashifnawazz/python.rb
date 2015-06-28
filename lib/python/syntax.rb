require 'python/pyobject'
require 'python/builtins'

module Python
  module Syntax
    class Statement
      def attrs
        []
      end

      def eval_proc
        proc{}
      end

      def initialize(*args)
        min_argc = attrs.take_while{|attr| attr.is_a?(Symbol)}.count
        max_argc = attrs.flatten.count
        unless min_argc <= args.length && args.length <= max_argc
          raise "Argument error: failed to make instance of #{self.class.name}." +
                "expected: #{attrs}, actual: #{args}"
        end
        attrs.flatten.zip(args).each do |name, val|
          instance_variable_set("@#{name}".to_sym, val)
        end
      end

      def eval(env)
        instance_exec(env, &eval_proc)
      end

      def ==(other)
        self.class == other.class && attrs.flatten.all? do |vname|
          ivname = "@#{vname}".to_sym
          self.instance_variable_get(ivname) == other.instance_variable_get(ivname)
        end
      end
    end
    Expression = Class.new(Statement)

    def self.stmt(*attrs, &eval)
      define_element_type(Statement, *attrs, &eval)
    end

    def self.exp(*attrs, &eval)
      define_element_type(Expression, *attrs, &eval)
    end

    def self.define_element_type(base, *attrs, &eval_proc)
      cls = Class.new(base)
      cls.send(:define_method, :attrs) { attrs }
      cls.send(:define_method, :eval_proc) { eval_proc }
      cls.send(:attr_reader, *attrs.flatten)
      return cls
    end

    def self.draw_syntax_tree(val, depth=0)
      case val
      when  Statement
        puts ("  " * depth) + "Node<#{val.class.name}>:"
        val.attrs.flatten.each do |attrname|
          puts ("  " * (depth + 1)) + "#{attrname}:"
          draw_syntax_tree(val.instance_variable_get("@#{attrname}".to_sym), depth + 2)
        end
      when Array
        val.each_with_index do |v, i|
          puts ("  " * (depth + 1)) + "[#{i}]"
          draw_syntax_tree(v, depth + 2)
        end
      else
        puts ("  " * (depth + 1)) + val.to_s
      end
    end

    # Exceptions possibly occurring when evaluating
    PyBoolizeError = Class.new(RuntimeError)
    PyNameError = Class.new(RuntimeError)
    PyCallError = Class.new(RuntimeError)

    def self.pytrue?(object)
      boolized = object.call_special_method("__bool__")
      if boolized == Builtins::True
        return true
      elsif boolized == Builtins::False
        return false
      else
        raise PyBoolizeError.new
      end
    end

    #--------------------
    # AST-elements of Statements
    #--------------------

    StatementList = stmt(:stmts) do |env|
      @stmts.inject(nil) do |acc, stmt|
        stmt.eval(env)
      end
    end

    AssignIdentifier = stmt(:name, :exp) do |env|
      env.set(@name, @exp.eval(env))
      nil
    end

    AssignAttr = stmt(:receiver, :attrname, :exp) do |env|
      @receiver.eval(env).set_attr(@attrname, @exp.eval(env))
      nil
    end

    Def = stmt(:name, :stat, :fix_param_names, [:rest_param_name]) do |env|
      entity = {:fix_param_names => @fix_param_names,
                :rest_param_name => @rest_param_name,
                :stat => @stat,
                :env => env.getlink}
      env.set(@name, Builtins::Func.make_instance(entity))
      nil
    end

    ClassDef = stmt(:name, :stat, :base_exps) do |env|
      bases = @base_exps.map{|e| e.eval(env)}
      klassenv = ClassEnvironment.new(:parent => env)
      stat.eval(klassenv)
      klass = PyObject.new(klassenv.merge(:class => Builtins::Type, :bases => bases))
      env.set(@name, klass)
      nil
    end

    Return = stmt([:exp]) do |env|
      res = if @exp then @exp.eval(env) else Builtins::None end
      throw :return, res
    end

    #--------------------
    # AST-elements of Expressions
    #--------------------

    Apply = exp(:callee_exp, :arg_exps) do |env|
      @callee_exp.eval(env).call(*@arg_exps.map{|e| e.eval(env)})
    end

    AttrRef = exp(:receiver, :attrname) do |env|
      @receiver.eval(env).get_attr(@attrname)
    end

    RefIdentifier = exp(:name) do |env|
      if res = env.resolve(@name)
        res
      else
        raise PyNameError.new("Unbound variable: #{@name}")
      end
    end

    Conditional = exp(:cond_exp, :true_exp, :false_exp) do |env|
      if Syntax.pytrue?(@cond_exp.eval(env))
        @true_exp.eval(env)
      else
        @false_exp.eval(env)
      end
    end

    UnaryOp = exp(:op_name, :exp) do |env|
      @exp.eval(env).call_special_method(@op_name)
    end

    BinaryOp = exp(:op_name, :left_exp, :right_exp) do |env|
      left = @left_exp.eval(env)
      right = @right_exp.eval(env)
      left.call_special_method(@op_name, right)
    end

    And = exp(:left_exp, :right_exp) do |env|
      left = @left_exp.eval(env)
      if !Syntax.pytrue?(left)
        left
      else
        @right_exp.eval(env)
      end
    end

    Or = exp(:left_exp, :right_exp) do |env|
      left = @left_exp.eval(env)
      if Syntax.pytrue?(left)
        left
      else
        @right_exp.eval(env)
      end
    end

    Not = exp(:cond_exp) do |env|
      if Syntax.pytrue?(@cond_exp.eval(env))
        Builtins::False
      else
        Builtins::True
      end
    end

    LiteralObject = exp(:object) do |env|
      @object
    end
  end
end
