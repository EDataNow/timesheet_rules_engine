require 'rspec'
require 'ostruct'
require 'timesheet_rules_engine'

describe TimesheetRulesEngine do
  context 'standard criteria and shift' do
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

    context 'worked all scheduled hours and days' do
    end
  end
end