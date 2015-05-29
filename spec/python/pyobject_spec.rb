require 'spec_helper'

module Python
  describe PyObject do
    describe "#get_special_attr" do
      it "gets special attr of direct-class" do
        cls = PyObject.new("__xxx__" => PyObject.new(:entity => 1))
        obj = PyObject.new(:class => cls)
        expect(obj.get_special_attr("__xxx__")).to eq(PyObject.new(:entity => 1))
      end

      it "gets special attr of base-class" do
        base = PyObject.new("__xxx__" => PyObject.new(:entity => 1))
        dire = PyObject.new(:bases => [base])
        obj = PyObject.new(:class => dire)
        expect(obj.get_special_attr("__xxx__")).to eq(PyObject.new(:entity => 1))        
      end
    end
  end
end
