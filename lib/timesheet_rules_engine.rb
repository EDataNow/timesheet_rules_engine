require 'processors/timesheet'

class TimesheetRulesEngine
  DEFAULTS = { rules: [], include_rules: [], exclude_rules: [] }

  attr_reader :current_weekly_hours, :gets_bonus_overtime, :total_overtime

  def initialize(timesheets=[], options={})
    @timesheets = timesheets
    @options = DEFAULTS.merge(options.symbolize_keys)

    @current_weekly_hours = 0.0
    @gets_bonus_overtime = true
  end

  def process_timesheets
    if @timesheets.any? {|t| t.left_early? }
      @gets_bonus_overtime = false
    end

    @timesheets.map do |timesheet|
      timesheet = Processors::Timesheet.new(timesheet, @options.merge({current_weekly_hours: @current_weekly_hours,
                                                                       left_early: timesheet.left_early,
                                                                       gets_bonus_overtime: @gets_bonus_overtime})).process_timesheet

      @current_weekly_hours += timesheet.total
      @total_overtime += timesheet.overtime

      timesheet
    end
  end
end