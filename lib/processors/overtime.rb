require 'byebug'
require 'active_support/all'
Dir["lib/rules/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Overtime
    DEFAULT_OVERTIME_RULES = [
                               'IsOvertimeDay',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
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
      if is_overtime_paid? && has_minimum_weekly_hours?
        if is_overtime_day?
          @base.processed_activity[:overtime] = @base.activity.total_hours
        end
      end

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

    def is_overtime_day?
      rule_included?("IsOvertimeDay") ? Rules::IsOvertimeDay.new(@base).check : true
    end

    def rule_included?(rule)
      @rules.include?(rule)
    end
  end
end