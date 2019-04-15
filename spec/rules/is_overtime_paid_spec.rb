require 'rspec'
require 'rules/is_overtime_paid'

module Rules
  describe IsOvertimePaid do
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

      context 'when overtime activity is paid' do
        let(:paid) { IsOvertimePaid.new(nil, OpenStruct.new(attributes_for(:activity)), criteria) }
        subject { paid.process_activity }

        it "should do nothing" do
          paid.processed_activity.overtime = 1.0

          expect(subject.overtime).to eq(1.0)
          expect(subject.total).to eq(1.0)
        end
      end

      context 'when overtime activity is not paid' do
        let(:paid) { IsOvertimePaid.new(nil, OpenStruct.new(attributes_for(:activity, paid_overtime: false)), criteria) }
        subject { paid.process_activity }

        it "should make regular be the total hours to be the same as total hours" do
          expect(subject.regular).to eq(1.0)
          expect(subject.total).to eq(1.0)
        end
      end


    end
  end
end