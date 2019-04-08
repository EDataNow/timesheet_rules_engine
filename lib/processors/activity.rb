require 'byebug'
require 'active_support/all'
Dir["lib/rules/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Activity
    DEFAULT_ACTIVITY_RULES = [
                               'IsOvertimeDay',
                               'IsLunch',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                               'IsOutsideRegularSchedule',
                               "IsPartialOvertimeDay",
                               "MaximumDailyHours",
                               "MinimumWeeklyHours"
                             ]
    attr_reader :base, :rules

    def initialize(base, rules=[])
      @base = base
      @rules = rules.empty? ? DEFAULT_ACTIVITY_RULES : rules
    end

    def calculate_hours
      if is_overtime_paid? && is_overtime_activity_type?
        if is_lunch?
          @base.processed_activity[:lunch] = @base.activity.total_hours
        elsif is_overtime_day?
          @base.processed_activity[:overtime] = @base.activity.total_hours
        elsif is_partial_overtime_day?
          @base.processed_activity[:overtime] = Rules::IsPartialOvertimeDay.new(@base).calculate_overtime
          @base.processed_activity[:regular] = @base.activity.total_hours - @base.processed_activity[:overtime]
        elsif is_outside_regular_schedule?
          hours = Rules::IsOutsideRegularSchedule.new(@base).calculate_hours
          @base.processed_activity[:overtime] = hours.overtime
          @base.processed_activity[:regular] = hours.regular
        else
          @base.processed_activity[:regular] = @base.activity.total_hours
        end
      else
        @base.processed_activity[:regular] = @base.activity.total_hours
      end
    end

    private

    def is_overtime_paid?
      rule_included?("IsOvertimePaid") ? Rules::IsOvertimePaid.new(@base).check : true
    end

    def is_overtime_activity_type?
      rule_included?("IsOvertimeActivityType") ? Rules::IsOvertimeActivityType.new(@base).check : true
    end

    def is_partial_overtime_day?
      rule_included?("IsPartialOvertimeDay") ? Rules::IsPartialOvertimeDay.new(@base).check : false
    end

    def is_overtime_day?
      rule_included?("IsOvertimeDay") ? Rules::IsOvertimeDay.new(@base).check : false
    end

    def is_outside_regular_schedule?
      rule_included?("IsOutsideRegularSchedule") ? Rules::IsOutsideRegularSchedule.new(@base).check : false
    end

    def is_lunch?
      rule_included?("IsLunch") ? Rules::IsLunch.new(@base).check : false
    end

    def rule_included?(rule)
      @rules.include?(rule)
    end
  end
end