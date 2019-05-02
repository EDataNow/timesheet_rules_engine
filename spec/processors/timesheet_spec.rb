require 'rspec'
require 'ostruct'
require 'processors/timesheet'

module Processors
  describe Timesheet do
    let(:criteria) {
         {
            minimum_daily_hours: 3.0,
            maximum_daily_hours: 8.0,
            minimum_weekly_hours: 44.0,
            maximum_weekly_hours: 60.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-04 7:00am"),
                                ended_at: DateTime.parse("2019-04-04 3:00pm"))
          }
      }

    describe 'rules and activities' do
      context 'worked on an overtime day and all paid' do
        let(:criteria) {
         {
            minimum_daily_hours: 3.0,
            maximum_daily_hours: 8.0,
            minimum_weekly_hours: 44.0,
            maximum_weekly_hours: 60.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-06 7:00am"),
                                ended_at: DateTime.parse("2019-04-06 3:00pm"))
          }
        }

        it "should calculate to have all hours in overtime except training and lunch" do
          activities = [
            OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-06 7:00am"),
                                                                    to: DateTime.parse("2019-04-06 7:23am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-06 7:25am"),
                                                                    to: DateTime.parse("2019-04-06 8:00am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "downtime", from: DateTime.parse("2019-04-06 8:00am"),
                                                                    to: DateTime.parse("2019-04-06 8:35am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-06 8:35am"),
                                                                    to: DateTime.parse("2019-04-06 9:20am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-06 9:20am"),
                                                                    to: DateTime.parse("2019-04-06 10:00am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "lunch", from: DateTime.parse("2019-04-06 10:00am"),
                                                                    to: DateTime.parse("2019-04-06 11:00am"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "training", from: DateTime.parse("2019-04-06 11:00am"),
                                                                    to: DateTime.parse("2019-04-06 12:00pm"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-06 12:00pm"),
                                                                    to: DateTime.parse("2019-04-06 1:45pm"), total_hours: 1.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-06 1:45pm"),
                                                                    to: DateTime.parse("2019-04-06 2:30pm"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "other", from: DateTime.parse("2019-04-06 2:30pm"),
                                                                    to: DateTime.parse("2019-04-06 3:00pm"), total_hours: 0.50))
          ]

          result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)), {criteria: criteria}).process_timesheet

          expect(result.regular).to eq(1.0)
          expect(result.overtime).to eq(6.0)
        end
      end

      context 'worked on a regular day and all paid' do
        context 'left early but for a legit reason and worked under minimum daily hours' do
          it "should have a minimum regular of 3.0 and a regular of 1.0" do
            activities = [
              OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-04 7:00am"),
                                                                      to: DateTime.parse("2019-04-04 7:30am"), total_hours: 0.50)),
              OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 7:30am"),
                                                                      to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50))
            ]

            result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities, left_early: false)), {criteria: criteria}).process_timesheet

            expect(result.regular).to eq(1.0)
            expect(result.overtime).to eq(0.0)
            expect(result.minimum_regular).to eq(3.0)
          end
        end

        context 'left early for a not legit reason and worked under minimum daily hours' do
          it "should have a minimum regular of 3.0 and a regular of 1.0" do
            activities = [
              OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-04 7:00am"),
                                                                      to: DateTime.parse("2019-04-04 7:30am"), total_hours: 0.50)),
              OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 7:30am"),
                                                                      to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50))
            ]

            result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities, left_early: true)), {criteria: criteria, left_early: true}).process_timesheet

            expect(result.regular).to eq(1.0)
            expect(result.overtime).to eq(0.0)
            expect(result.minimum_regular).to eq(0.0)
          end
        end

        it "should calculate to have 8 regular hours and 0 overtime hour when they came in early but worked scheduled hours with realistic times" do
          activities = [
            OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-04 6:00am"),
                                                                    to: DateTime.parse("2019-04-04 7:23am"), total_hours: 1.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 7:25am"),
                                                                    to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "downtime", from: DateTime.parse("2019-04-04 8:00am"),
                                                                    to: DateTime.parse("2019-04-04 8:35am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 8:35am"),
                                                                    to: DateTime.parse("2019-04-04 9:20am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 9:20am"),
                                                                    to: DateTime.parse("2019-04-04 10:00am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "lunch", from: DateTime.parse("2019-04-04 10:00am"),
                                                                    to: DateTime.parse("2019-04-04 11:00am"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "training", from: DateTime.parse("2019-04-04 11:00am"),
                                                                    to: DateTime.parse("2019-04-04 12:00pm"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 12:00pm"),
                                                                    to: DateTime.parse("2019-04-04 1:45pm"), total_hours: 1.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 1:45pm"),
                                                                    to: DateTime.parse("2019-04-04 2:30pm"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "other", from: DateTime.parse("2019-04-04 2:30pm"),
                                                                    to: DateTime.parse("2019-04-04 3:00pm"), total_hours: 0.50))
          ]

          result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)), {criteria: criteria}).process_timesheet

          expect(result.regular).to eq(8.0)
          expect(result.lunch).to eq(1.0)
          expect(result.total).to eq(9.0)
          expect(result.overtime).to eq(0.0)
        end

        it "should calculate to have 8 regular hours and 1 overtime hour when they came in early but worked scheduled hours" do
          activities = [
            OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-04 5:00am"),
                                                                    to: DateTime.parse("2019-04-04 7:30am"), total_hours: 2.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 7:30am"),
                                                                    to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "downtime", from: DateTime.parse("2019-04-04 8:00am"),
                                                                    to: DateTime.parse("2019-04-04 8:30am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 8:30am"),
                                                                    to: DateTime.parse("2019-04-04 9:15am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 9:15am"),
                                                                    to: DateTime.parse("2019-04-04 10:00am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "lunch", from: DateTime.parse("2019-04-04 10:00am"),
                                                                    to: DateTime.parse("2019-04-04 11:00am"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "training", from: DateTime.parse("2019-04-04 11:00am"),
                                                                    to: DateTime.parse("2019-04-04 12:00pm"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 12:00pm"),
                                                                    to: DateTime.parse("2019-04-04 1:45pm"), total_hours: 1.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 1:45pm"),
                                                                    to: DateTime.parse("2019-04-04 2:30pm"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "other", from: DateTime.parse("2019-04-04 2:30pm"),
                                                                    to: DateTime.parse("2019-04-04 3:00pm"), total_hours: 0.50))
          ]

          result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)), {criteria: criteria}).process_timesheet

          expect(result.regular).to eq(8.0)
          expect(result.overtime).to eq(1.0)
        end

        it "should calculate to have 7 regular hours and 0 overtime hours when they worked exactly scheduled hours" do
          activities = [
            OpenStruct.new(attributes_for(:activity, kind: "shift_prep", from: DateTime.parse("2019-04-04 7:00am"),
                                                                    to: DateTime.parse("2019-04-04 7:30am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 7:30am"),
                                                                    to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "downtime", from: DateTime.parse("2019-04-04 8:00am"),
                                                                    to: DateTime.parse("2019-04-04 8:30am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 8:30am"),
                                                                    to: DateTime.parse("2019-04-04 9:15am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 9:15am"),
                                                                    to: DateTime.parse("2019-04-04 10:00am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "lunch", from: DateTime.parse("2019-04-04 10:00am"),
                                                                    to: DateTime.parse("2019-04-04 11:00am"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "training", from: DateTime.parse("2019-04-04 11:00am"),
                                                                    to: DateTime.parse("2019-04-04 12:00pm"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 12:00pm"),
                                                                    to: DateTime.parse("2019-04-04 1:45pm"), total_hours: 1.75)),
            OpenStruct.new(attributes_for(:activity, kind: "job", from: DateTime.parse("2019-04-04 1:45pm"),
                                                                    to: DateTime.parse("2019-04-04 2:30pm"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, kind: "other", from: DateTime.parse("2019-04-04 2:30pm"),
                                                                    to: DateTime.parse("2019-04-04 3:00pm"), total_hours: 0.50))
          ]

          result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)), {criteria: criteria}).process_timesheet

          expect(result.regular).to eq(7.0)
          expect(result.overtime).to eq(0.0)
        end
      end
    end

    describe 'no rules and no activities' do
      subject { Timesheet.new(OpenStruct.new(attributes_for(:timesheet_no_activities)),
                                            {no_rules: true, criteria: criteria}).process_timesheet }

      it 'should contain proper defaults' do
        expect(subject.id).to eq(1)
        expect(subject.regular).to eq(0.0)
        expect(subject.overtime).to eq(0.0)
        expect(subject.total).to eq(0.0)
      end
    end

    describe 'no rules and has activities' do
      let(:activities) {
        [
          OpenStruct.new(attributes_for(:activity)),
          OpenStruct.new(attributes_for(:activity, id: 2)),
          OpenStruct.new(attributes_for(:activity, id: 3))
        ]
      }

      subject { Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)),
                                            {no_rules: true, criteria: criteria}).process_timesheet }

      it 'should calculate billable, regular and total to be the same' do
        expect(subject.id).to eq(1)
        expect(subject.regular).to eq(3.0)
        expect(subject.overtime).to eq(0.0)
        expect(subject.total).to eq(3.0)
      end
    end
  end
end