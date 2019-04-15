require 'rspec'
require 'rules/ca/on/maximum_daily_hours'
require 'rules/base'

module Rules
  module Ca
    module On
      describe MaximumDailyHours do
        describe 'processing' do
          let(:criteria) {
            {
                minimum_daily_hours: 0.0,
                maximum_daily_hours: 8.0,
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

          context 'when activity is over maximum daily hours' do
            subject { MaximumDailyHours.check(41.0, 40.0) }

            it "should be beyond maximum daily hours" do
              expect(subject).to be true
            end
          end

          context 'when activity is not over maximum daily hours' do
            subject { MaximumDailyHours.check(25.0, 25.0) }

            it "should not be beyond maximum daily hours" do
              expect(subject).to be false
            end
          end


        end
      end
    end
  end
end