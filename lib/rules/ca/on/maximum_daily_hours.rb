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
            @processed_activity[:overtime] = @activity.total_hours

            @base.stop = true
          end
        end

        def check
          @base.current_daily_hours > @base.maximum_daily_hours
        end

        def self.check(current_daily_hours, maximum_daily_hours)
          current_daily_hours > maximum_daily_hours
        end
      end
    end
  end
end