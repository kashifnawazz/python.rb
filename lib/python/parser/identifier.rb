require 'python/parser/combinator'

module Python
  module Parser
    class IdentifierParser < Combinator
      parser :identifier do # -> String
        token(xid_start >> proc{|head|
          many(xid_continue) >> proc{|rests|
            ret(head + rests.inject("", &:+))
          }})
      end

      parser :xid_start do # -> Char (1-lenght String)
        any_char("A".."Z") | any_char("a".."z") | char("_")
      end

      parser :xid_continue do # -> Char (1-lenght String)
        xid_start | any_char("0".."9")
      end
    end
  end
end
