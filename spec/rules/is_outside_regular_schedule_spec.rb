require 'rspec'
require 'rules/is_outside_regular_schedule'

module Rules
  describe IsOutsideRegularSchedule do
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
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                            ended_at: DateTime.parse("2018-01-01 4:30pm"))
          }
      }

      context 'when activity is outside regular schedule' do
        let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, from: DateTime.parse("2018-01-01 5:00am"),
                                                                        to: DateTime.parse("2019-01-01 4:30pm"))), criteria) }

        it "should check as true" do
          expect(schedule.check).to be true
        end

        it "should calculate the right overtime and regular hours" do
          subject = schedule.process_activity

          expect(subject.regular).to eq(10.5)
          expect(subject.overtime).to eq(1.0)
        end
      end

      context 'when activity is not outside regular schedule' do
        let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, from: DateTime.parse("2018-01-01 6:00am"),
                                                                        to: DateTime.parse("2019-01-01 4:30pm"))), criteria) }

        it "should check as true" do
          expect(schedule.check).to be false
        end

        it "should calculate the right overtime and regular hours" do
          subject = schedule.process_activity

          expect(subject.regular).to eq(10.5)
          expect(subject.overtime).to eq(0.0)
        end
      end


    end
  end
end