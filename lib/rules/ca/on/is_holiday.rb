require 'rules/base'
require 'holidays'
require 'holidays/core_extensions/date'
require 'active_support/all'
require 'holidays/core_extensions/time'

class Time
  include Holidays::CoreExtensions::Time
end

class DateTime
  include Holidays::CoreExtensions::Date
end

module Rules
  module Ca
    module On
      class IsHoliday < ::Rules::Base
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
          is_holiday?
        end

        def method_missing(method, *args)
          if @criteria.has_key?(method)
            @criteria[method]
          else
            super
          end
        end

        private

        def is_holiday?(field_to_check=nil)
          holidays_overtime && @activity.from.to_datetime.holiday?(@base.full_region) && @activity.to.to_datetime.holiday?(@base.full_region)
        end
      end
    end
  end
end