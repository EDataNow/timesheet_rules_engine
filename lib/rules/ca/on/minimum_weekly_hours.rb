require 'rules/base'

module Rules
  module Ca
    module On
      class MinimumWeeklyHours
        def initialize
        end

        def self.check(current_weekly_hours, minimum_weekly_hours)
          current_weekly_hours > minimum_weekly_hours
        end
      end
    end
  end
end