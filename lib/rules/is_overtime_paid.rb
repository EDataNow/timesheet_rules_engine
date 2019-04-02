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
                  closest_minute: 8.0
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
      end
    end

    def process_activity
      if @activity.paid_overtime
        @processed_activity[:payable] = @processed_activity[:overtime]
        @processed_activity[:total] = @activity.total_hours
      end

      @processed_activity
    end
  end
end