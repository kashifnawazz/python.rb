require 'spec_helper'

module Python
  module Parser
    describe IndentConverter do
      describe "#convert" do
        it "convert indent" do

input_code = <<CODE
def aaa():
  def bbb():
        def ccc():
          x = 1 + 1
          return 123
  return ccc

aaa()
CODE

expected_code = <<CODE
def aaa():
$Idef bbb():
$Idef ccc():
$Ix = 1 + 1
return 123
$D$Dreturn ccc
$D
aaa()

CODE
          expect(IndentConverter.new.convert(input_code)).to eq(expected_code)
        end
      end
    end
  end
end
