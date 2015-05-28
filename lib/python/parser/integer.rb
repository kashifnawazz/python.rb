require 'python/parser/combinator'

module Python
  module Parser
    class IntegerParser < Combinator
      parser :integer do # -> Integer
        token(decimalinteger)
      end

      parser :decimalinteger do # -> Integer
        nonzero = nonzerodigit >> proc{|head|
          many(digit) >> proc{|tail|
            ret((head + tail.inject("", &:+)).to_i)
          }}
        zero = many1(char("0")) >> proc{|zs| ret(0)}
        nonzero | zero
      end

      parser :nonzerodigit do # -> Char (1-length String)
        any_char("1".."9")
      end

      parser :digit do # -> Char (1-length String)
        any_char("0".."9")
      end
    end
  end
end
