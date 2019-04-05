require 'rules/base'
require 'processors/activity'
Dir["rules/*.rb"].each {|file| require file }
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
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
    DEFAULTS = {
                  rules: [
                            "IsOvertimeDay",
                            'IsPartialOvertimeDay',
                            'IsPaid',
                            "isOvertimePaid",
                            "isBilled"
                         ],
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
                  # gets_bonus_overtime: true
                }

    attr_reader :timesheet, :rules

    attr_accessor :current_weekly_hours, :current_daily_hours, :total_overtime

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                        regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})
      @timesheet = timesheet
      @options = DEFAULTS.merge(options.symbolize_keys)
      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]
      @gets_bonus_overtime = @options[:gets_bonus_overtime]

      @options[:exclude_rules].each {|er| @options[:rules].reject!{|r| r == er }}
      unless @options[:include_rules].empty?
        @options[:rules] = @options[:include_rules]
      end

      # if @gets_bonus_overtime
      #   @options[:criteria][:minimum_weekly_hours] -= @options[:criteria][:overtime_reduction]
      # end

      if @options[:criteria][:scheduled_shift].nil?
        @options[:criteria][:scheduled_shift] = timesheet.shift
      end
    end

    def process_timesheet
      activities = @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                                     current_daily_hours: @result_timesheet.total,
                                                                     left_early: @left_early,
                                                                     gets_bonus_overtime: @gets_bonus_overtime })

        if @options[:rules].present?
          Activity.new(base_rule, DEFAULT_OVERTIME_RULES.reject{|r| @options[:exclude_rules].include?(r) }).calculate_hours
        else
          base_rule.process_activity
        end

        # if @options[:rules].empty?
        #   base_rule.process_activity
        # else
        #   @options[:rules].each do |rule|
        #     "Rules::#{rule}".constantize.send(:new, base_rule).process_activity

        #     # if base_rule.stop
        #     #   break
        #     # end
        #   end
        # end

        [:billable, :regular, :payable, :overtime, :downtime, :lunch, :total].each do |attribute|
          @result_timesheet[attribute] += base_rule.processed_activity[attribute]
        end

        base_rule.processed_activity
      end

      @result_timesheet
    end
  end
end