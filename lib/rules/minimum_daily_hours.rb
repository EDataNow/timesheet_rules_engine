require 'rules/base'

module Rules
  class MinimumDailyHours < Base
    def initialize
    end

    def self.check(current_daily_hours, minimum_daily_hours)
      current_daily_hours > minimum_daily_hours
    end
  end
end