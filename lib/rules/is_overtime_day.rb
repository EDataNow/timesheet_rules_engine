require 'rules/base'
require 'active_support/all'

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
                  region: "ca_on",
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
        @base = self
      end
    end

    def process_activity
      if check && @processed_activity[:overtime] == 0.0
        @processed_activity[:regular] = 0.0
        @processed_activity[:raw_regular] = 0.0
        @processed_activity[:overtime] = @activity.total_hours
        @processed_activity[:raw_overtime] = @activity.total_hours * 3600.0
      end

      @processed_activity
    end

    def check
      is_overtime_day
    end

    def is_overtime_day
      is_overtime_days?
    end

    def method_missing(method, *args)
      if @criteria.has_key?(method)
        @criteria[method]
      else
        super
      end
    end

    private

    def is_overtime_days?
      overtime_days.any? {|d| @activity.from.send("#{d}?") } && overtime_days.any? {|d| @activity.to.send("#{d}?") }
    end

  end
end