require 'byebug'
require 'active_support/all'
Dir["lib/rules/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Overtime
    DEFAULT_OVERTIME_RULES = [
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
      @rules = rules.empty? ? DEFAULT_OVERTIME_RULES : rules
    end

    def calculate_hours
      if is_overtime_paid? && is_overtime_activity_type?
        if is_lunch?
          @base.processed_activity[:regular] -= @base.activity.total_hours
        elsif is_overtime_day?
          @base.processed_activity[:overtime] = @base.activity.total_hours
        # elsif has_maximum_daily_hours?
        #   @base.processed_activity[:regular] = @base.maximum_daily_hours - @base.current_daily_hours
        #   @base.processed_activity[:overtime] = @base.activity.total_hours - @base.processed_activity[:regular]
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
      # if !@base.left_early && is_overtime_paid? && has_minimum_weekly_hours? && is_overtime_activity_type?
      #   if is_overtime_day?
      #     @base.processed_activity[:overtime] = @base.activity.total_hours
      #   elsif has_maximum_daily_hours?
      #     @base.processed_activity[:overtime] = @base.activity.total_hours - (@base.maximum_daily_hours - @base.current_daily_hours)
      #   elsif is_partial_overtime_day?
      #     @base.processed_activity[:overtime] = Rules::IsPartialOvertimeDay.new(@base).calculate_overtime
      #   end
      # end

      # @rules.each do |rule|
      #   "Rules::#{rule}".constantize.send(:new, base_rule).process_activity
      # end
    end

    private

    def is_overtime_paid?
      rule_included?("IsOvertimePaid") ? Rules::IsOvertimePaid.new(@base).check : true
    end

    def has_minimum_weekly_hours?
      rule_included?("MinimumWeeklyHours") ? Rules::MinimumWeeklyHours.new(@base).check : true
    end

    def is_overtime_activity_type?
      rule_included?("IsOvertimeActivityType") ? Rules::IsOvertimeActivityType.new(@base).check : true
    end

    def has_maximum_daily_hours?
      rule_included?("MaximumDailyHours") ? Rules::MaximumDailyHours.new(@base).check : false
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