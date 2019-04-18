require 'rules/base'

module Rules
  module Ca
    module On
      class MinimumDailyHours < ::Rules::Base
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

        def self.check(current_daily_hours, minimum_daily_hours)
          current_daily_hours > minimum_daily_hours
        end
      end
    end
  end
end