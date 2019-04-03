require 'processors/timesheet'
require 'processors/timesheets'

class TimesheetRulesEngine
  DEFAULTS = { shift: nil, rules: [], criteria: [], include_rules: [], exclude_rules: [] }

  attr_reader :current_weekly_hours, :gets_bonus_overtime, :total_overtime, :total_hours, :left_early

  def initialize(timesheets=[], options={})
    @timesheets = timesheets
    @options = DEFAULTS.merge(options.symbolize_keys)

    @current_weekly_hours = 0.0
    @total_hours = 0.0
    @total_overtime = 0.0
    @gets_bonus_overtime = true
    @left_early = false
  end

  def process_timesheets
    if @timesheets.any? {|t| t.left_early? }
      @gets_bonus_overtime = false
      @left_early = true
    end

    @result_timesheets = @timesheets.map do |timesheet|
      timesheet = Processors::Timesheet.new(timesheet, @options.merge({current_weekly_hours: @current_weekly_hours,
                                                                       left_early: timesheet.left_early,
                                                                       gets_bonus_overtime: @gets_bonus_overtime})).process_timesheet

      @current_weekly_hours += timesheet.regular
      @total_overtime += timesheet.overtime
      @total_hours += timesheet.total

      timesheet
    end

    Processors::Timesheets.new(@timesheets, @options, { left_early: @left_early,
                                                        current_weekly_hours: @current_weekly_hours,
                                                        gets_bonus_overtime: @gets_bonus_overtime,
                                                        total_overtime: @total_overtime,
                                                        total_hours: @total_hours }).process_timesheets
  end
end