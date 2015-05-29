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
      self[:entity].call(*args)
    end

    def call_special_method(method_name, *args)
      get_special_attr(method_name).call(*args)
    end

    def get_special_attr(name)
      if !self[:class]
        raise "failed to get special attr #{name} from #{self}: #{self} doesn't have class"
      elsif cls = self[:class].cls_traverse{|cls| cls[name] && cls[name].datadescriptor?}
        cls[name].get_get_method.call(cls[name], self, self[:class])
      elsif cls = self[:class].cls_traverse{|cls| cls[name]}
        if cls[name].descriptor?
          cls[name].get_get_method.call(cls[name], self, self[:class])
        else
          cls[name]
        end
      else
        raise "failed to get special attr #{name} from #{self}: #{name} is not found"
      end
    end

    def get_get_method
      cls = self[:class].cls_traverse{|cls| cls["__get__"]}
      cls["__get__"]
    end

    def descriptor?
      self[:class] && self[:class].cls_traverse{|cls| cls["__get__"]}
    end

    def datadescriptor?
      descriptor? && self[:class].cls_traverse{|cls| cls["__get__"] || cls["__delete__"]}
    end

    def cls_traverse(&proc)
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
        "<class:#{self[:name]}>"
      elsif self[:class] && self[:class][:name]
        "<instance:#{self[:class][:name]}"
      else
        super
      end
    end
  end
end
