require 'rspec'
require 'rules/base'

module Rules
  describe Base do
    describe 'processing' do
      subject { Base.new(OpenStruct.new(attributes_for(:activity))).process_activity }

      it "should calculate billable, regular and total to be the same as total hours" do
        expect(subject.id).to eq(1)
        expect(subject.billable).to eq(1.0)
        expect(subject.regular).to eq(1.0)
        expect(subject.overtime).to eq(0.0)
        expect(subject.total).to eq(1.0)
      end
    end
  end
end