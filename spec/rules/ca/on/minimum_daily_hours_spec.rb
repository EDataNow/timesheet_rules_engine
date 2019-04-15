require 'rspec'
require 'rules/ca/on/minimum_daily_hours'
require 'rules/base'

module Rules
  module Ca
    module On
      describe MinimumDailyHours do
        describe 'processing' do
          let(:criteria) {
            {
                minimum_daily_hours: 3.0,
                maximum_daily_hours: 8.0,
                minimum_weekly_hours: 40.0,
                maximum_weekly_hours: 60.0,
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

          context 'when activity is goes beyond minimum daily hours' do
            subject { MinimumDailyHours.check(4.0, 3.0) }

            it "should be beyond minimum daily hours" do
              expect(subject).to be true
            end
          end

          context 'when activity is not over minimum daily hours' do
            subject { MinimumDailyHours.check(1.0, 3.0) }

            it "should not be beyond minimum daily hours" do
              expect(subject).to be false
            end
          end


        end
      end
    end
  end
end