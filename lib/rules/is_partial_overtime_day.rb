require 'rules/base'
require 'holidays'
require 'holidays/core_extensions/date'
require 'active_support/all'

class DateTime
  include Holidays::CoreExtensions::Date
end

module Rules
  class IsPartialOvertimeDay < Base
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
                  closest_minute: 8.0
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
      if is_partial_overtime_day
        if @partial_overtime_time_field == "from"
          from = @activity.from
          to = @activity.to

          time_difference = (to.midnight.to_i - from.to_i) / 3600
        elsif @partial_overtime_time_field == "to"
          to = @activity.to

          time_difference = (to.to_i - to.midnight.to_i) / 3600
        end

        @processed_activity[:regular] = @activity.total_hours - time_difference
        @processed_activity[:overtime] = time_difference
        @processed_activity[:total] = @activity.total_hours
      end

      @processed_activity
    end

    def is_partial_overtime_day
      is_from_overtime_day = overtime_days.any? {|d| @activity.from.send("#{d}?") }
      is_from_holiday = is_holiday?("from")
      is_to_holiday = is_holiday?("to")
      is_to_overtime_day = overtime_days.any? {|d| @activity.to.send("#{d}?") }

      if is_from_overtime_day || is_from_holiday
        @partial_overtime_time_field = "from"
      elsif is_to_overtime_day || is_to_holiday
        @partial_overtime_time_field = "to"
      end

      is_from_overtime_day || is_to_overtime_day || is_from_holiday || is_to_holiday
    end

    private

    def is_overtime_days?
      overtime_days.any? {|d| @activity.from.send("#{d}?") } && overtime_days.any? {|d| @activity.to.send("#{d}?") }
    end

    def is_holiday?(field_to_check=nil)
      if holidays_overtime
        if field_to_check
          @activity.send(field_to_check).holiday?(:ca_on)
        else
          @activity.from.holiday?(:ca_on) && @activity.to.holiday?(:ca_on)
        end
      else
        false
      end
    end

  end
end