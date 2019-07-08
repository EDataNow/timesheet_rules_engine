require 'rules/base'

module Rules
  module Ca
    module On
      class MinimumWeeklyHours < ::Rules::Base
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
            @processed_activity[:overtime] = @base.current_weekly_hours - @base.minimum_weekly_hours
            @processed_activity[:regular] = @base.minimum_weekly_hours
            @processed_activity[:raw_regular] = @processed_activity[:regular] * 3600.0
            @processed_activity[:raw_overtime] = @processed_activity[:overtime] * 3600.0

            @base.stop = true
          end
        end

        def check
          @base.current_weekly_hours > @base.minimum_weekly_hours
        end

        def self.check(current_weekly_hours, minimum_weekly_hours)
          current_weekly_hours > minimum_weekly_hours
        end
      end
    end
  end
end