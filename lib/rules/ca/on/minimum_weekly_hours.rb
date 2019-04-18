require 'rules/base'

module Rules
  module Ca
    module On
      class MinimumWeeklyHours
        def initialize(base, activity=nil, criteria=nil)
          if base
            @base = base
          else
            super(activity, criteria)
            @base = self
          end
        end

        def process_activity
        end

        def self.check(current_weekly_hours, minimum_weekly_hours)
          current_weekly_hours > minimum_weekly_hours
        end
      end
    end
  end
end