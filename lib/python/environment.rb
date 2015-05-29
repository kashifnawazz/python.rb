require 'python/builtins'

module Python
  class Environment < Hash
    def resolve(name)
      case name
      when "True"
        Builtins::True
      when "False"
        Builtins::False
      when "None"
        Builtins::None
      else
        self[name]
      end
    end

    def set(name, pyobj)
      self[name] = pyobj
    end
  end
end
