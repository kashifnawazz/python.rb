module Python
  class PyObject < Hash
    def initialize(attr={})
      self.merge!(attr)
    end

    def make_instance(entity=nil, &entity_proc)
      PyObject.new(:class => self, :entity => entity || entity_proc)
    end

    def entity
      self[:entity]
    end

    def call(*args)
      if self[:entity] && self[:entity].is_a?(Proc)
        self[:entity].call(*args)
      else
        call_special_method("__call__", *args)
      end
    end

    def call_special_method(method_name, *args)
      get_special_attr(method_name).call(*args)
    end

    def get_special_attr(name)
      if !self[:class]
        raise "failed to get special attr #{name} from #{self}: #{self} doesn't have class"
      elsif cls = self[:class].base_traverse{|cls| cls[name] && cls[name].datadescriptor?}
        cls[name].get_get_method.call(cls[name], self, self[:class])
      elsif cls = self[:class].base_traverse{|cls| cls[name]}
        if cls[name].descriptor?
          cls[name].get_get_method.call(cls[name], self, self[:class])
        else
          cls[name]
        end
      else
        raise "failed to get special attr #{name} from #{self}: #{name} is not found"
      end
    end

    def has_special_attr?(name)
      get_special_attr(name)
    rescue
      nil
    end

    def get_attr(name)
      if !self[:class]
        raise "failed to get attr #{name} from #{self}: #{self} doesn't have class"
      elsif cls = self[:class].base_traverse{|cls| cls[name] && cls[name].datadescriptor?}
        cls[name].get_get_method.call(cls[name], self, self[:class])
      elsif owner = self.base_traverse{|owner| owner[name]}
        owner[name]
      elsif cls = self[:class].base_traverse{|cls| cls[name]}
        if cls[name].descriptor?
          cls[name].get_get_method.call(cls[name], self, self[:class])
        else
          cls[name]
        end
      else
        raise "failed to get attr #{name} from #{self}: #{name} is not found"
      end
    end

    def has_attr?(name)
      get_attr(name)
    rescue
      nil
    end

    def set_attr(name, pyobj)
      if !self[:class]
        raise "failed to set attr #{name} on #{self}: #{self} doesn't have class"
      elsif cls = self[:class].base_traverse{|cls| cls[name] && cls[name].datadescriptor?}
        cls[name].get_set_method.call(cls[name], self, pyobj)
      else
        self[name] = pyobj
      end
    end

    def get_get_method
      cls = self[:class].base_traverse{|cls| cls["__get__"]}
      cls["__get__"]
    end

    def descriptor?
      self[:class] && self[:class].base_traverse{|cls| cls["__get__"]}
    end

    def get_set_method
      cls = self[:class].base_traverse{|cls| cls["__set__"] || cls["__delete__"]}
      unless cls["__set__"]
        raise "cannot set data on datadescriptor '#{cls}'"
      else
        cls["__set__"]
      end
    end

    def datadescriptor?
      descriptor? && self[:class].base_traverse{|cls| cls["__set__"] || cls["__delete__"]}
    end

    def base_traverse(&proc)
      queue = [self]
      until queue.empty?
        cls = queue.pop
        if judge = proc.call(cls)
          return cls
        end
        queue += (cls[:bases] || [])
      end
      return nil
    end

    def inspect
      if self[:name]
        self[:name]
      elsif self[:entity]
        self[:entity].to_s
      elsif self[:class] && self[:class][:name]
        "<instance of:#{self[:class][:name]}"
      else
        super
      end
    end
  end
end
