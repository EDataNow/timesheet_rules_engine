require 'rules/base'

module Rules
  class IsOvertimePaid < Base
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
        @base = base
      else
        super(activity, criteria)
        @base = self
      end
    end

    def check
      @activity.paid_overtime
    end

    def process_activity
      unless check
        @processed_activity[:overtime] = 0.0
        @processed_activity[:raw_overtime] = 0.0
        @processed_activity[:regular] = @activity.total_hours
        @processed_activity[:raw_regular] = @activity.total_hours * 3600.0

        @base.stop = true
      end

      @processed_activity
    end
  end
end