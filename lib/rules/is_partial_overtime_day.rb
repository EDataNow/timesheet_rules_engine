require 'rules/base'
require 'util/time_adjuster'
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
                  closest_minute: 8.0,
                  region: "ca_on",
                  scheduled_shift: nil
                }

    attr_reader :criteria, :activity, :processed_activity, :base

    def initialize(base, activity=nil, criteria=nil, context=nil)
      if base
        @activity = base.activity
        @criteria = base.criteria
        @processed_activity = base.processed_activity
        @partial_overtime_time_field = nil
        @base = base
      else
        super(activity, criteria)
        @base = self
      end

      process_dates
    end

    def process_dates
      new_dates = Util::TimeAdjuster.new(@activity.from, @activity.to).process_dates

      @from = new_dates.from
      @to = new_dates.to
    end

    def process_activity
      if is_partial_overtime_day && @processed_activity[:overtime] == 0.0
        time_difference = calculate_overtime

        @processed_activity[:regular] = @activity.total_hours - time_difference
        @processed_activity[:overtime] = time_difference
      end

      @processed_activity
    end

    def calculate_overtime
      is_partial_overtime_day

      if @partial_overtime_time_field == "from"
        time_difference = ((@to.midnight.to_i - @from.to_i) / 3600.0).round(decimal_place)
      elsif @partial_overtime_time_field == "to"
        time_difference = ((@to.to_i - @to.midnight.to_i) / 3600.0).round(decimal_place)
      elsif @partial_overtime_time_field == "both"
        time_difference = @activity.total_hours
      end

      time_difference
    end

    def check
      is_partial_overtime_day
    end

    def is_partial_overtime_day
      is_from_overtime_day = overtime_days.any? {|d| @from.send("#{d}?") }
      is_from_holiday = is_holiday?("from")
      is_to_holiday = is_holiday?("to")
      is_to_overtime_day = overtime_days.any? {|d| @to.send("#{d}?") }

      if (is_to_overtime_day && is_from_holiday) || (is_from_overtime_day && is_to_holiday)
        @partial_overtime_time_field = "both"
      elsif is_from_overtime_day || is_from_holiday
        @partial_overtime_time_field = "from"
      elsif is_to_overtime_day || is_to_holiday
        @partial_overtime_time_field = "to"
      end

      is_from_overtime_day || is_to_overtime_day || is_from_holiday || is_to_holiday
    end

    private

    def is_overtime_days?
      overtime_days.any? {|d| @from.send("#{d}?") } && overtime_days.any? {|d| @to.send("#{d}?") }
    end

    def is_holiday?(field_to_check=nil)
      if holidays_overtime
        if field_to_check
          self.instance_variable_get("@#{field_to_check}").holiday?(@base.full_region)
        else
          @from.holiday?(@base.full_region) && @to.holiday?(@base.full_region)
        end
      else
        false
      end
    end

  end
end