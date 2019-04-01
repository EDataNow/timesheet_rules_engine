require 'rspec'
require 'ostruct'
require 'processors/timesheet'

module Processors
  describe Timesheet do
    subject { Timesheet.new(OpenStruct.new(attributes_for(:timesheet)),
                              { criteria: {
                                              minimum_daily_hours: 0.0,
                                              maximum_daily_hours: 0.0,
                                              minimum_weekly_hours: 0.0,
                                              maximum_weekly_hours: 0.0,
                                              saturdays_overtime: true,
                                              sundays_overtime: true,
                                              holidays_overtime: true,
                                              decimal_place: 2,
                                              billable_hour: 0.25,
                                              closest_minute: 8.0
                                            }
                              }).process_timesheet }

    it "should have a timesheet with a shift" do
      expect(subject.id).to eq(1)
    end
  end
end