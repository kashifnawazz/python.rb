require 'python/pyobject'

module Python
  module Builtins
    Func = PyObject.new(:name => "Func")
    Int = PyObject.new(:name => "Int")
    Bool = PyObject.new(:name => "Bool", :bases => [Int])

    None = PyObject.new(:name => "None")
    True = PyObject.new(:class => Bool, :name => "True", :entity => 1)
    False = PyObject.new(:class => Bool, :name => "False", :entity => 0)

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

    Func["__get__"] = Func.make_instance{|_self, obj, objtype| Func.make_instance{|*args| _self.call(obj, *args)}}
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
  end
end
