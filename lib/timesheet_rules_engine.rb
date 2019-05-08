require 'processors/timesheet'
require 'processors/timesheets'
require 'util/time_adjuster'
require 'require_all'

require_all 'lib'

class TimesheetRulesEngine
  DEFAULTS = { include_rules: [], exclude_rules: [], no_rules: false,
               country: "ca", region: "on", exclude_incentive_rules: false
             }

  attr_reader :current_weekly_hours, :left_early

  def initialize(timesheets=[], options={})
    @timesheets = timesheets
    @options = DEFAULTS.merge(options.symbolize_keys)
    @region = "#{@options[:country]} #{@options[:region]}"

    @current_weekly_hours = 0.0
    @left_early = false
  end

  def process_timesheets
    @left_early = @timesheets.any?(&:left_early)

    @result_timesheets = @timesheets.map do |timesheet|
      timesheet = Processors::Timesheet.new(timesheet,
                                            @options.merge({
                                                            current_weekly_hours: @current_weekly_hours,
                                                            left_early: @left_early
                                                          })
                                            ).process_timesheet

      @current_weekly_hours += timesheet.total

      timesheet
    end

    @result = Processors::Timesheets.new(@result_timesheets, @options.merge({ left_early: @left_early,
                                                                              current_weekly_hours: @current_weekly_hours })).process_timesheets

    @result[:processed_timesheets] = @result_timesheets

    @result
  end
end