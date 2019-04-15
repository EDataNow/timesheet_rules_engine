require 'rspec'
require 'rules/ca/on/maximum_weekly_hours'
require 'rules/base'

module Rules
  module Ca
    module On
      describe MaximumWeeklyHours do
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

          context 'when current weekly is over maximum weekly hours' do
            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 61.0, current_daily_hours: 40.0}) }
            let(:max) { MaximumWeeklyHours.new(base) }
            subject { max.check }

            it "should be beyond maximum weekly hours" do
              expect(subject).to be true
            end
          end

          context 'when current weekly is not over maximum weekly hours' do
            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 30.0, current_daily_hours: 25.0}) }
            let(:max) { MaximumWeeklyHours.new(base) }
            subject { max.check }

            it "should not be beyond maximum weekly hours" do
              base.processed_activity.regular = 4.0
              expect(subject).to be false
            end
          end


        end
      end
    end
  end
end