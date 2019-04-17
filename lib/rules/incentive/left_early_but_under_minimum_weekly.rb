require 'rules/base'

module Rules
  module Incentive
    class LeftEarlyButUnderMinimumWeekly < ::Rules::Base
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
        if check
          @processed_activity.regular += @processed_activity.overtime
          @processed_activity.overtime = 0.0

          @base.stop = true
        end

        @processed_activity
      end

      def check
        @base.left_early && !has_minimum_weekly_hours?
      end

      def has_minimum_weekly_hours?
        @base.current_weekly_hours > @base.minimum_weekly_hours
      end
    end
  end
end