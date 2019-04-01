require 'rspec'
require 'rules/base_rule'

module Rules
  describe Base do

    subject { Base.new(attributes_for(:activity)) }

    it "should have a timesheet with a shift" do

    end
  end
end