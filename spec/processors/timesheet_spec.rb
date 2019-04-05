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
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-04 7:00am"),
                                ended_at: DateTime.parse("2019-04-04 3:00pm"))
          }
      }

    describe 'rules and activities' do
      context 'worked regular hours on a regular day and all paid' do
        it "should have calculate to have 7 regular hours and 0 overtime hours when they worked exactly scheduled hours" do
          activities = [
            OpenStruct.new(attributes_for(:activity, type: "shift_prep", from: DateTime.parse("2019-04-04 7:00am"),
                                                                    to: DateTime.parse("2019-04-04 7:30am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, type: "job", from: DateTime.parse("2019-04-04 7:30am"),
                                                                    to: DateTime.parse("2019-04-04 8:00am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, type: "downtime", from: DateTime.parse("2019-04-04 8:00am"),
                                                                    to: DateTime.parse("2019-04-04 8:30am"), total_hours: 0.50)),
            OpenStruct.new(attributes_for(:activity, type: "job", from: DateTime.parse("2019-04-04 8:30am"),
                                                                    to: DateTime.parse("2019-04-04 9:15am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, type: "job", from: DateTime.parse("2019-04-04 9:15am"),
                                                                    to: DateTime.parse("2019-04-04 10:00am"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, type: "lunch", from: DateTime.parse("2019-04-04 10:00am"),
                                                                    to: DateTime.parse("2019-04-04 11:00am"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, type: "training", from: DateTime.parse("2019-04-04 11:00am"),
                                                                    to: DateTime.parse("2019-04-04 12:00pm"), total_hours: 1.0)),
            OpenStruct.new(attributes_for(:activity, type: "job", from: DateTime.parse("2019-04-04 12:00pm"),
                                                                    to: DateTime.parse("2019-04-04 1:45pm"), total_hours: 1.75)),
            OpenStruct.new(attributes_for(:activity, type: "job", from: DateTime.parse("2019-04-04 1:45pm"),
                                                                    to: DateTime.parse("2019-04-04 2:30pm"), total_hours: 0.75)),
            OpenStruct.new(attributes_for(:activity, type: "other", from: DateTime.parse("2019-04-04 2:30pm"),
                                                                    to: DateTime.parse("2019-04-04 3:00pm"), total_hours: 0.50))
          ]

          result = Timesheet.new(OpenStruct.new(attributes_for(:timesheet_with_activities, activities: activities)), {criteria: criteria}).process_timesheet

          expect(result.regular).to eq(7.0)
          expect(result.overtime).to eq(0.0)
        end
      end

      context 'came in earlier than scheduled but worked entire scheduled shift' do
      end
    end
    describe 'no rules and no activities' do
      subject { Timesheet.new(OpenStruct.new(attributes_for(:timesheet_no_activities)),
                                            {criteria: criteria}).process_timesheet }

      it 'should contain proper defaults' do
        expect(subject.id).to eq(1)
        expect(subject.billable).to eq(0.0)
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
                                            {rules: [], criteria: criteria}).process_timesheet }

      it 'should calculate billable, regular and total to be the same' do
        expect(subject.id).to eq(1)
        expect(subject.billable).to eq(3.0)
        expect(subject.regular).to eq(3.0)
        expect(subject.overtime).to eq(0.0)
        expect(subject.total).to eq(3.0)
      end
    end
  end
end