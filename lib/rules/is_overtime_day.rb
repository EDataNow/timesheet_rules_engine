require 'rules/base'
require 'holidays'
require 'holidays/core_extensions/date'
require 'active_support/all'

class DateTime
  include Holidays::CoreExtensions::Date
end

module Rules
  class IsOvertimeDay < Base
    DEFAULTS = {  minimum_daily_hours: 0.0,
                  maximum_daily_hours: 0.0,
                  minimum_weekly_hours: 0.0,
                  maximum_weekly_hours: 0.0,
                  overtime_days: ["saturday", "sunday"],
                  saturdays_overtime: true,
                  sundays_overtime: true,
                  holidays_overtime: true,
                  decimal_place: 2,
                  billable_hour: 0.25,
                  closest_minute: 8.0,
                  scheduled_shift: nil
                }

    attr_reader :criteria, :activity, :processed_activity, :base

    def initialize(base, activity=nil, criteria=nil)
      if base
        @activity = base.activity
        @criteria = base.criteria
        @processed_activity = base.processed_activity
        @partial_overtime_time_field = nil
        @base = base
      else
        super(activity, criteria)
      end
    end

    def process_activity
      if is_overtime_day
        @processed_activity[:regular] = 0.0
        @processed_activity[:overtime] = @activity.total_hours
      end

      @processed_activity
    end

    def is_overtime_day
      is_overtime_days? || is_holiday?
    end

    private

    def is_overtime_days?
      overtime_days.any? {|d| @activity.from.send("#{d}?") } && overtime_days.any? {|d| @activity.to.send("#{d}?") }
    end

    def is_holiday?(field_to_check=nil)
      holidays_overtime && @activity.from.holiday?(:ca_on) && @activity.to.holiday?(:ca_on)
    end

  end
end