require 'rspec'
require 'ostruct'
require 'processors/timesheet'

module Processors
  describe Timesheet do
    describe 'no rules and no activities' do
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
            overtime_reduction: 0.0
          }
      }

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
            overtime_reduction: 0.0
          }
      }

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