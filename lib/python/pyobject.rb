module Python
  class PyObject
    def initialize(meta_data)
      @meta_data = meta_data
    end

    def entity
      @meta_data[:entity]
    end

    def ==(other)
      self.entity == other.entity
    end

    def call_special_method(method_name, *args)
      case method_name
      when "__add__"
        PyObject.new(:entity => self.entity + args[0].entity)
      when "__sub__"
        PyObject.new(:entity => self.entity - args[0].entity)
      when "__mul__"
        PyObject.new(:entity => self.entity * args[0].entity)
      when "__floordiv__"
        PyObject.new(:entity => self.entity / args[0].entity)
      when "__pos__"
        PyObject.new(:entity => + self.entity)
      when "__neg__"
        PyObject.new(:entity => - self.entity)
      end
    end
  end
end
