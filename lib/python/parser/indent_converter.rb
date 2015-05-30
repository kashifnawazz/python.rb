module Python
  class IndentConverter
    IndentConversionError = Class.new(RuntimeError)

    INDENT = "$I"
    DEDENT = "$D"
    NEWLINE = "\n"

    def convert(str)
      stack = [0]
      converted_lines = []
      str.gsub("\r\n", "\n").gsub("\r", "\n").split("\n").each do |line|
        ilevel = indent_level(line)
        if ilevel > stack.last
          stack << ilevel
          converted_lines << convert_line(line, INDENT)
        elsif ilevel < stack.last
          dedent_livel = 0
          while ilevel < stack.last
            dedent_livel += 1
            stack.pop
          end
          unless ilevel == stack.last
            raise IndentConversionError.new
          end
          converted_lines << convert_line(line, DEDENT * dedent_livel)
        else
          converted_lines << convert_line(line, "")
        end
      end
      converted_lines.join(NEWLINE)
    end

    def indent_level(line)
      line.chars.take_while{|c| c == "\s" || c == "\t"}.inject(0) do |acc, c|
        case c
        when "\s"
          acc + 1
        when "\t"
          acc - (acc % 8) + 8
        end
      end
    end

    def convert_line(line, token)
      token + line.chars.drop_while{|c| c == "\s" || c == "\t"}.inject("", &:+)
    end
  end
end
