require 'rules/base'

module Rules
  module Ca
    module On
      class MaximumDailyHours < ::Rules::Base
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

        def process_activity
          if check && @processed_activity[:overtime] == 0.0
            unless @base.current_daily_hours > @base.maximum_daily_hours
              @processed_activity[:regular] = @base.maximum_daily_hours - @base.current_daily_hours
              @processed_activity[:raw_regular] = @processed_activity[:regular] * 3600.0
            end

            @processed_activity[:overtime] = @activity.total_hours - @processed_activity[:regular]
            @processed_activity[:raw_overtime] = @processed_activity[:overtime] * 3600.0

            @base.stop = true
          end
        end

        def check
          (@base.current_daily_hours + @activity.total_hours) > @base.maximum_daily_hours
        end

        def self.check(current_daily_hours, maximum_daily_hours)
          current_daily_hours > maximum_daily_hours
        end
      end
    end
  end
end