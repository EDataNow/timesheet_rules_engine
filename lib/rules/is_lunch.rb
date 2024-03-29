require 'rules/base'

module Rules
  class IsLunch < Base
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
      @activity.kind == "lunch"
    end

    def process_activity
      if check
        @processed_activity[:payable] = 0.0
        @processed_activity[:billable] = 0.0
        @processed_activity[:regular] = 0.0
        @processed_activity[:raw_regular] = 0.0
        @processed_activity[:overtime] = 0.0
        @processed_activity[:raw_overtime] = 0.0
        @processed_activity[:lunch] = @activity.total_hours

        @base.stop = true
      end

      @processed_activity
    end
  end
end