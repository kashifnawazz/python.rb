require 'python/builtins'

module Python
  class Environment < Hash
    def initialize(initial_attr={})
      self.merge!(initial_attr)
    end

    def resolve(name)
      if self[name]
        self[name]
      elsif self[:parent]
        self[:parent].resolve(name)
      else
        case name
        when "True"
          Builtins::True
        when "False"
          Builtins::False
        when "None"
          Builtins::None
        when "print"
          Builtins::Print
        end
      end
    end

    def set(name, pyobj)
      self[name] = pyobj
    end
  end
end
