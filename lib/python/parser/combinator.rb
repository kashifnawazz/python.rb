module Python
  module Parser
    Result = Class.new
    Failed = Class.new(Result)
    Succeeded = Class.new(Result)

    class Succeeded
      attr_reader :parsed, :rest
      def initialize(parsed, rest)
        @parsed, @rest = parsed, rest
      end
    end

    class Combinator
      ParserDefinitionError = Class.new(RuntimeError)

      attr_accessor :f
      def initialize(&proc)
        @f = proc
      end

      def parse(inp)
        @f.call(inp)
      end

      def >>(proc)
        self.class.so(self, &proc)
      end

      def |(other)
        self.class.either(self, other)
      end

      def +(other)
        self.class.discardl(self, other)
      end

      def -(other)
        self.class.discardr(self, other)
      end

      def self.ret(something)
        new{|inp| Succeeded.new(something, inp)}
      end

      def self.failure
        new{|inp| Failed.new}
      end

      def self.item
        new{|inp| inp.size == 0 ? Failed.new : Succeeded.new(inp[0], inp[1, inp.size - 1])}
      end

      def self.so(parser, &proc)
        new{|inp|
          case result = parser.parse(inp)
          when Failed
            result
          when Succeeded
            proc.call(result.parsed).parse(result.rest)
          else
            raise "error."
          end
        }
      end

      def self.either(parser1, parser2)
        new{|inp|
          case result = parser1.parse(inp)
          when Failed
            parser2.parse(inp)
          when Succeeded
            result
          else
            raise "error."
          end
        }
      end

      def self.discardl(parser1, parser2)
        parser1 >> proc{parser2}
      end

      def self.discardr(parser1, parser2)
        parser1 >> proc{|x|
          parser2 >> proc{
            ret(x)
          }}
      end

      def self.separator(element_parser, separating_token_str)
        element_parser >> proc{|x|
          many(token_str(separating_token_str) + element_parser) >> proc{|xs|
            ret([x] + xs)
          }}
      end

      def self.separator_allow_empty(element_parser, separating_token_str)
        separator(element_parser, separating_token_str) | ret([])
      end

      def self.optional(parser)
        (parser >> proc{|x| ret([x])}) | ret([])
      end

      def self.many(parser)
        many1(parser) | ret([])
      end

      def self.many1(parser)
        parser >> proc{|x|
          many(parser) >> proc{|xs|
            ret([x] + xs)
          }}
      end

      def self.sat(&proc)
        item >> proc{|c|
          proc.call(c) ? ret(c) : failure
        }
      end

      def self.char(char)
        sat{|c| c == char}
      end

      def self.any_char(x)
        case x
        when String
          chars = x.cahrs.map{|c| char(c)}
          if chars.length < 0
            raise ParserDefinitionError.new
          else
            chars.inject(&:|)
          end
        when Range
          chars = x.map{|c| char(c)}
          if chars.length < 0
            raise ParserDefinitionError.new
          else
            chars.inject(&:|)
          end
        else
          raise ParserDefinitionError.new
        end
      end

      def self.string(str)
        if str.size == 0
          ret(str)
        else
          char(str[0]) >> proc{|c|
            string(str[1, str.size - 1]) >> proc{
              ret(str)
            }
          }
        end
      end

      def self.whitespace
        many(char("\s") | char("\t")) >> proc{|ws|
          ret(:whitespace)
        }
      end

      def self.token(parser)
        whitespace >> proc{
          parser >> proc{|x|
            whitespace >> proc{
              ret(x)
            }}}
      end

      def self.token_str(str)
        token(string(str))
      end

      def self.binopl(parser, op_proc_parser)
        rest = proc{|a|
          op_proc_parser >> proc{|f|
            parser >> proc{|b|
              rest.call(f.call(a, b))
            }} | ret(a)
        }
        parser >> proc{|a|
          rest.call(a)
        }
      end

      def self.parser(name, &proc)
        @cache ||= {}
        spcls = class << self; self end
        spcls.send(:define_method, name) do |*args|
          key = [name, args]
          if @cache[key]
            return @cache[key]
          else
            @cache[key] = self.new{}
            @cache[key].f = proc.call(*args).f
            return @cache[key]
          end
        end
      end
    end
  end
end
