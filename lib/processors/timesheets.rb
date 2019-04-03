require 'byebug'
require 'active_support/all'
Dir["lib/rules/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Timesheets
    DEFAULTS = {
                  rules: DEFAULT_WEEKLY_RULES,
                  criteria: {
                              minimum_daily_hours: 0.0,
                              maximum_daily_hours: 0.0,
                              minimum_weekly_hours: 0.0,
                              maximum_weekly_hours: 0.0,
                              overtime_days: ["saturday", "sunday"],
                              saturdays_overtime: true,
                              sundays_overtime: true,
                              holidays_overtime: true,
                              decimal_place: 2,
                              billable_hour: 0.25,
                              closest_minute: 8.0,
                              scheduled_shift: nil,
                            },
                  current_weekly_hours: 0.0,
                  include_rules: [],
                  exclude_rules: [],
                  left_early: false,
                  gets_bonus_overtime: true
                }

    DEFAULT_WEEKLY_RULES = [
                               'IsOvertimeDay',
                               'IsLunch',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                               "IsPartialOvertimeDay",
                               "MaximumDailyHours",
                               "MinimumWeeklyHours"
                             ]

    attr_reader :processed_timesheets, :rules, :gets_bonus_overtime

    attr_accessor :current_weekly_hours, :current_daily_hours, :total_overtime

    def initialize(processed_timesheets, options, context)
      @options = DEFAULTS.merge(options.symbolize_keys)

      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]
      @gets_bonus_overtime = @options[:gets_bonus_overtime]

      @options[:exclude_rules].each {|er| @options[:rules].reject!{|r| r == er }}
      unless @options[:include_rules].empty?
        @options[:rules] = @options[:include_rules]
      end

      if @gets_bonus_overtime
        @options[:criteria][:minimum_weekly_hours] -= @options[:criteria][:overtime_reduction]
      end

      if @options[:criteria][:scheduled_shift].nil?
        @options[:criteria][:scheduled_shift] = @options[:shift]
      end

      @process_timesheets = process_timesheets
      rules = @options[:rules]

      @rules = rules.empty? ? DEFAULT_OVERTIME_RULES : rules
    end

    def process_timesheets
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

      { regular: 0.0, total: 0.0, overtime: 0.0, billable: 0.0, payable: 0.0 }
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

    def is_lunch?
      rule_included?("IsLunch") ? Rules::IsLunch.new(@base).check : false
    end

    def rule_included?(rule)
      @rules.include?(rule)
    end
  end
end