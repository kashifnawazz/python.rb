require 'python/pyobject'

module Python
  module Builtins
    # Primitive objects
    Func = PyObject.new(:name => "Func")
    Int = PyObject.new(:name => "Int")
    Bool = PyObject.new(:name => "Bool", :bases => [Int])

    None = PyObject.new(:name => "None")
    True = PyObject.new(:class => Bool, :name => "True", :entity => 1)
    False = PyObject.new(:class => Bool, :name => "False", :entity => 0)

    Type = PyObject.new(:name => "Type")


    # Primitiv functions
    AddTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity + b.entity)}
    SubTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity - b.entity)}
    MulTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity * b.entity)}
    FloordivTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity / b.entity)}
    PosInt = Func.make_instance{|n| Int.make_instance(+ n.entity)}
    NegInt = Func.make_instance{|n| Int.make_instance(- n.entity)}
    EQInt = Func.make_instance{|a, b| a.entity == b.entity ? True : False}
    LTInt = Func.make_instance{|a, b| a.entity < b.entity ? True : False}
    GTInt = Func.make_instance{|a, b| a.entity > b.entity ? True : False}
    IntToBool = Func.make_instance{|n| n.entity == 0 ? False : True}

    Print = Func.make_instance{|o| puts(o.inspect)}
    ClosureCall = Func.make_instance do |f, *args|
      if f.entity[:rest_param_name]
        unless f.entity[:fix_param_names].length <= args.length
          raise Syntax::PyCallError.new
        end
      else
        unless f.entity[:fix_param_names].length == args.length
          raise Syntax::PyCallError.new
        end
      end
      bind = f.entity[:fix_param_names].zip(args).to_h
      env = Environment.new(bind.merge(:parent => f.entity[:env]))
      catch(:return) { f.entity[:stat].eval(env) } || None
    end

    MakeInstance = Func.make_instance do |cls, *args|
      if class_having_new = cls.base_traverse{|cls| cls["__new__"]}
        madeobj = class_having_new["__new__"].call(*args)
      else
        madeobj = PyObject.new(:class => cls)
      end
      if madeobj[:class] == cls && madeobj.has_special_attr?("__init__")
        madeobj.call_special_method("__init__", *args)
      end
      madeobj
    end

    # Method binds of primitive functions
    Func["__get__"] = Func.make_instance{|_self, obj, objtype| Func.make_instance{|*args| _self.call(obj, *args)}}
    Func["__call__"] = Func.make_instance{|_self, *args| ClosureCall.call(_self, *args)}
    Int["__add__"] = Func.make_instance{|_self, other| AddTwoInt.call(_self, other)}
    Int["__sub__"] = Func.make_instance{|_self, other| SubTwoInt.call(_self, other)}
    Int["__mul__"] = Func.make_instance{|_self, other| MulTwoInt.call(_self, other)}
    Int["__floordiv__"] = Func.make_instance{|_self, other| FloordivTwoInt.call(_self, other)}
    Int["__pos__"] = Func.make_instance{|_self| PosInt.call(_self)}
    Int["__neg__"] = Func.make_instance{|_self| NegInt.call(_self)}
    Int["__bool__"] = Func.make_instance{|_self| IntToBool.call(_self)}
    Int["__eq__"] = Func.make_instance{|_self, other| EQInt.call(_self, other)}
    Int["__lt__"] = Func.make_instance{|_self, other| LTInt.call(_self, other)}
    Int["__gt__"] = Func.make_instance{|_self, other| GTInt.call(_self, other)}
    Type["__call__"] = Func.make_instance{|_self, *args| MakeInstance.call(_self, *args)}
  end
end
