require 'rules/base'
require 'processors/activity'
Dir["rules/*.rb"].each {|file| require file }
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
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
    DEFAULT_TIMESHEET_RULES =  [
                                'MinimumDailyHours'
                               ]
    DEFAULTS = {
                  criteria: {
                              minimum_daily_hours: 3.0,
                              maximum_daily_hours: 8.0,
                              minimum_weekly_hours: 44.0,
                              maximum_weekly_hours: 60.0,
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
                  no_rules: false,
                  left_early: false,
                  # gets_bonus_overtime: true
                }

    attr_reader :timesheet, :rules

    attr_accessor :current_weekly_hours, :current_daily_hours

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                        regular: 0.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})
      @timesheet = timesheet
      @options = DEFAULTS.merge(options.symbolize_keys)
      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = timesheet.left_early
      @gets_bonus_overtime = @options[:gets_bonus_overtime]

      unless @options[:include_rules].empty?
        @rules = @options[:include_rules]
      else
        @rules = DEFAULT_TIMESHEET_RULES
      end
      @options[:exclude_rules].each {|er| @rules.reject!{|r| r == er }}

      if timesheet.shift
        @options[:criteria][:scheduled_shift] = timesheet.shift
      end
    end

    def process_timesheet
      activities = @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                                     current_daily_hours: @result_timesheet.total,
                                                                     left_early: @left_early,
                                                                     gets_bonus_overtime: @gets_bonus_overtime })

        if @options[:no_rules]
          base_rule.process_activity
        else
          activity_rules = DEFAULT_ACTIVITY_RULES.reject{|r| @options[:exclude_rules].include?(r)}
          if @options[:include_rules].present?
            activity_rules = @options[:include_rules]
          end

          Activity.new(base_rule, activity_rules).calculate_hours
        end


        [:billable, :regular, :payable, :overtime, :downtime, :lunch, :total].each do |attribute|
          @result_timesheet[attribute] += base_rule.processed_activity[attribute]
        end

        base_rule.processed_activity
      end

      if qualifies_for_minimum_after_leaving_early?
        @result_timesheet[:minimum_regular] = @options[:criteria][:minimum_daily_hours]
      end

      @result_timesheet
    end

    def has_minimum_daily_hours?
      rule_included?("MinimumDailyHours") ? Rules::MinimumDailyHours.check(@result_timesheet.total, @options[:criteria][:minimum_daily_hours]) : true
    end

    def left_early_but_under_minimum?
      @left_early && !has_minimum_daily_hours?
    end

    def qualifies_for_minimum_after_leaving_early?
      !@left_early && !has_minimum_daily_hours?
    end

    def rule_included?(rule)
      @rules.include?(rule)
    end

  end
end