require 'spec_helper'

module Python
  describe REPL do
    describe "#start" do
      it "prompts for the input" do
        output = double('output')
        repl = REPL.new(output)
        expect(output).to receive(:print).with("python.rb> ")
        repl.start
      end
    end
  end
end
