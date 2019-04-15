require 'rules/base'

module Rules
  module Ca
    module On
      class MinimumDailyHours < ::Rules::Base
        def initialize
        end

        def self.check(current_daily_hours, minimum_daily_hours)
          current_daily_hours > minimum_daily_hours
        end
      end
    end
  end
end