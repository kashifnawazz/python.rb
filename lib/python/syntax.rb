require 'python/pyobject'
require 'python/syntax_util'
require 'python/builtins'

module Python
  module Syntax
    extend SyntaxUtil

    Statement = Class.new
    Expression = Class.new(Statement)

    # Exceptions possibly occurring when evaluating
    PyBoolizeError = py_runtime_error()
    PyNameError = py_runtime_error()
    PyReturnException = py_runtime_error(:obj)
    PyCallError = py_runtime_error()

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

    Def = stmt(:name, :stat, :fix_param_names, [:rest_param_name]) do |env|
      entity = {:fix_param_names => @fix_param_names,
                :rest_param_name => @rest_param_name,
                :stat => @stat,
                :env => env}
      env.set(@name, Builtins::Func.make_instance(entity))
      nil
    end

    Return = stmt([:exp]) do |env|
      res = if @exp then @exp.eval(env) else Builtins::None end
      raise PyReturnException.new(res)
    end

    #--------------------
    # AST-elements of Expressions
    #--------------------

    Apply = exp(:callee_exp, :arg_exps) do |env|
      @callee_exp.eval(env).call(*@arg_exps.map{|e| e.eval(env)})
    end

    RefIdentifier = exp(:name) do |env|
      if res = env.resolve(@name)
        res
      else
        raise PyNameError.new
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
