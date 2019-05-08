require 'active_support/all'
# Dir["lib/rules/**/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Activity
    DEFAULT_ACTIVITY_RULES = [
                               'IsOvertimeDay',
                               'IsLunch',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                               "Ca::On::IsPartialOvertimeDay",
                               'Ca::On::IsHoliday'
                             ]
    attr_reader :base, :rules

    def initialize(base, rules=[])
      @base = base
      @rules = rules.empty? ? DEFAULT_ACTIVITY_RULES : rules
    end

    def calculate_hours
      @rules.each do |rule|
        get_clazz(rule).new(@base).process_activity

        break if @base.stop
      end

      if @base.processed_activity[:regular] == 0.0 &&
          @base.processed_activity[:overtime] == 0.0 &&
          @base.processed_activity[:lunch] == 0.0
        @base.processed_activity[:regular] = @base.activity.total_hours
      end

      # if is_lunch?
      #   @base.processed_activity[:lunch] = @base.activity.total_hours
      # elsif is_overtime_paid? && is_overtime_activity_type?
      #   if is_overtime_day? || is_holiday?
      #     @base.processed_activity[:overtime] = @base.activity.total_hours
      #   elsif is_partial_overtime_day?
      #     @base.processed_activity[:overtime] = ::Rules::IsPartialOvertimeDay.new(@base).calculate_overtime
      #     @base.processed_activity[:regular] = @base.activity.total_hours - @base.processed_activity[:overtime]
      #   else
      #     @base.processed_activity[:regular] = @base.activity.total_hours
      #   end
      # else
      #   @base.processed_activity[:regular] = @base.activity.total_hours
      # end
    end

    private

    def get_clazz(rule)
      begin
        Object.const_get("::Rules::#{rule}")
      rescue
        nil
      end
    end
  end
end