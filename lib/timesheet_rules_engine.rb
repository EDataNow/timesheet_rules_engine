require 'processors/timesheet'

class TimesheetRulesEngine
  DEFAULTS = { rules: [] }

  def initialize(timesheets=[], options={})
    @timesheets = timesheets
    @options = DEFAULTS.merge(options.symbolize_keys)
  end

  def process_timesheets
    @timesheets.map do |timesheet|
      Processors::Timesheet.new(timesheet, @options).process_timesheet
    end
  end
end