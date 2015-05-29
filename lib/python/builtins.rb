require 'python/pyobject'

module Python
  module Builtins
    Func = PyObject.new(:name => "Func")
    Int = PyObject.new(:name => "Int")

    AddTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity + b.entity)}
    SubTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity - b.entity)}
    MulTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity * b.entity)}
    FloordivTwoInt = Func.make_instance{|a, b| Int.make_instance(a.entity / b.entity)}
    PosInt = Func.make_instance{|n| Int.make_instance(+ n.entity)}
    NegInt = Func.make_instance{|n| Int.make_instance(- n.entity)}

    Func["__get__"] = Func.make_instance{|_self, obj, objtype| Func.make_instance{|*args| _self.call(obj, *args)}}
    Int["__add__"] = Func.make_instance{|_self, other| AddTwoInt.call(_self, other)}
    Int["__sub__"] = Func.make_instance{|_self, other| SubTwoInt.call(_self, other)}
    Int["__mul__"] = Func.make_instance{|_self, other| MulTwoInt.call(_self, other)}
    Int["__floordiv__"] = Func.make_instance{|_self, other| FloordivTwoInt.call(_self, other)}
    Int["__pos__"] = Func.make_instance{|_self| PosInt.call(_self)}
    Int["__neg__"] = Func.make_instance{|_self| NegInt.call(_self)}
  end
end
