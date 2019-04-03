require 'rules/base'

module Rules
  class IsOutsideRegularSchedule < Base
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

        assign_partial_field
      else
        super(activity, criteria)
      end
    end

    def check
      @partial_overtime_time_field.nil?
    end

    def calculate_hours

    end

    def process_activity
      calculate_hours if check

      @processed_activity
    end

    private

    def assign_partial_field
      base.scheduled_shift.started_at
      base.scheduled_shift.ended_at
    end
  end
end