require 'rspec'
require 'rules/is_overtime_activity_type'

module Rules
  describe IsOvertimeActivityType do
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

      context 'when activity is training' do
        let(:overtime) { IsOvertimeActivityType.new(nil, OpenStruct.new(attributes_for(:activity, type: "training")), criteria) }
        subject { overtime.check }

        it "should not qualify for overtime" do
          expect(subject).to be false
        end
      end

      context 'when activity is not training or travel' do
        let(:overtime) { IsOvertimeActivityType.new(nil, OpenStruct.new(attributes_for(:activity)), criteria) }
        subject { overtime.check }

        it "should quality for overtime" do
          expect(subject).to be true
        end
      end


    end
  end
end