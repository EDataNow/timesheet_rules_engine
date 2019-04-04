require 'rspec'
require 'rules/minimum_daily_hours'
require 'rules/base'

module Rules
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
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                            ended_at: DateTime.parse("2018-01-01 4:30pm"))
          }
      }

      context 'when activity is goes beyond minimum daily hours' do
        let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 59.0, current_daily_hours: 4.0}) }
        let(:min) { MinimumDailyHours.new(base) }
        subject { min.check }

        it "should be beyond minimum daily hours" do
          expect(subject).to be true
        end
      end

      context 'when activity is not over minimum daily hours' do
        let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 1.0)), criteria, {current_weekly_hours: 30.0, current_daily_hours: 1.0}) }
        let(:min) { MinimumDailyHours.new(base) }
        subject { min.check }

        it "should not be beyond minimum daily hours" do
          expect(subject).to be false
        end
      end


    end
  end
end