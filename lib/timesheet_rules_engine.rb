require 'processors/timesheet'
require 'processors/timesheets'
require 'util/time_adjuster'

require "rules/base"
require "rules/ca/on/minimum_weekly_hours"
require "rules/ca/on/is_holiday"
require "rules/ca/on/minimum_daily_hours"
require "rules/ca/on/maximum_weekly_hours"
require "rules/ca/on/is_partial_overtime_day"
require "rules/ca/on/maximum_daily_hours"
require "rules/is_overtime_activity_type"
require "rules/is_lunch"
require "rules/is_overtime_paid"
require "rules/incentive/left_early_but_under_minimum_weekly"
require "rules/incentive/qualifies_for_daily_overtime_after_leaving_early"
require "rules/incentive/qualifies_for_minimum_after_leaving_early"
require "rules/incentive/qualifies_for_weekly_overtime_after_leaving_early"
require "rules/is_outside_regular_schedule"
require "rules/is_billed"
require "rules/is_paid"
require "rules/is_downtime"
require "rules/is_overtime_day"


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

      @current_weekly_hours += timesheet.regular

      timesheet
    end

    @result = Processors::Timesheets.new(@result_timesheets, @options.merge({ left_early: @left_early,
                                                                              current_weekly_hours: @current_weekly_hours })).process_timesheets

    @result[:processed_timesheets] = @result_timesheets

    @result
  end
end