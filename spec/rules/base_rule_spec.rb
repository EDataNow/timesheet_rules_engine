require 'rspec'
require 'rules/base'

module Rules
  describe Base do
    describe 'processing' do
      let(:criteria) {
         {
            minimum_daily_hours: 0.0,
            maximum_daily_hours: 0.0,
            minimum_weekly_hours: 0.0,
            maximum_weekly_hours: 0.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                            ended_at: DateTime.parse("2018-01-01 4:30pm"))
          }
      }

      let(:base) { Base.new(OpenStruct.new(attributes_for(:activity)), criteria) }
      subject { base.process_activity }

      it "should calculate billable, regular and total to be the same as total hours" do
        expect(subject.id).to eq(1)
        expect(subject.regular).to eq(1.0)
        expect(subject.overtime).to eq(0.0)
        expect(subject.total).to eq(1.0)
      end

      it "should store the criteria of the activity" do
        expect(base.decimal_place).to eq(2)
      end
    end
  end
end