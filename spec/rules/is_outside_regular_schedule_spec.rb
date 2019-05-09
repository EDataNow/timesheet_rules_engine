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
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                            ended_at: DateTime.parse("2018-01-01 4:30pm"))
          }
      }

      context 'when activity is outside regular schedule' do
        context 'when activity started before scheduled start but ended on time' do
          let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, from: DateTime.parse("2018-01-01 5:03am"),
                                                                          to: DateTime.parse("2018-01-01 4:35pm"))), criteria) }

          it "should check as true" do
            expect(schedule.check).to be true
          end

          it "should calculate the right overtime and regular hours" do
            subject = schedule.process_activity

            expect(subject.regular).to eq(10.5)
            expect(subject.overtime).to eq(1.0)
            expect(subject.raw_regular).to eq(38088.0)
            expect(subject.raw_overtime).to eq(3420.0)
          end
        end

        context 'when activity started and ended before scheduled start' do
          let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 0.75, from: DateTime.parse("2018-01-01 5:16am"),
                                                                        to: DateTime.parse("2018-01-01 6:02am"))), criteria) }

          it "should check as true" do
            expect(schedule.check).to be true
          end

          it "should calculate the right overtime and regular hours" do
            subject = schedule.process_activity

            expect(subject.regular).to eq(0.0)
            expect(subject.overtime).to eq(0.75)
          end
        end

        context 'when activity started and ended after scheduled end' do
          let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 1.75, from: DateTime.parse("2018-01-01 5:16pm"),
                                                                        to: DateTime.parse("2018-01-01 7:02pm"))), criteria) }

          it "should check as true" do
            expect(schedule.check).to be true
          end

          it "should calculate the right overtime and regular hours" do
            subject = schedule.process_activity

            expect(subject.regular).to eq(0.0)
            expect(subject.overtime).to eq(1.75)
          end
        end

        context 'when activity started before scheduled end and ended after scheduled end' do
          let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 2.00, from: DateTime.parse("2018-01-01 4:00pm"),
                                                                        to: DateTime.parse("2018-01-01 6:02pm"))), criteria) }

          it "should check as true" do
            expect(schedule.check).to be true
          end

          it "should calculate the right overtime and regular hours" do
            subject = schedule.process_activity

            expect(subject.regular).to eq(0.50)
            expect(subject.overtime).to eq(1.50)
          end
        end
      end

      context 'when activity is not outside regular schedule' do
        let(:schedule) { IsOutsideRegularSchedule.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 10.5, from: DateTime.parse("2018-01-01 6:03am"),
                                                                        to: DateTime.parse("2018-01-01 4:25pm"))), criteria) }

        it "should check as true" do
          expect(schedule.check).to be false
        end

        it "should not calculate anything for the activity" do
          subject = schedule.process_activity

          expect(subject.regular).to eq(0.0)
          expect(subject.overtime).to eq(0.0)
        end
      end


    end
  end
end