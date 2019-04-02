require 'processors/timesheet'

class TimesheetRulesEngine
  DEFAULTS = { rules: [], include_rules: [], exclude_rules: [] }

  attr_reader :current_weekly_hours

  def initialize(timesheets=[], options={})
    @timesheets = timesheets
    @options = DEFAULTS.merge(options.symbolize_keys)

    @current_weekly_hours = 0.0
  end

  def process_timesheets
    @timesheets.map do |timesheet|
      timesheet = Processors::Timesheet.new(timesheet, @options.merge({current_weekly_hours: @current_weekly_hours})).process_timesheet

      @current_weekly_hours += timesheet.total

      timesheet
    end
  end
end