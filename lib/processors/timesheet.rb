Dir["lib/rules/**/**/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'processors/activity'
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
    DEFAULT_ACTIVITY_RULES = [
                               'IsOvertimeDay',
                               'IsLunch',
                               'Ca::On::IsHoliday',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                               "IsPartialOvertimeDay"
                             ]

    DEFAULT_TIMESHEET_RULES =  [
                                'Incentive::QualifiesForMinimumAfterLeavingEarly',
                                "Incentive::QualifiesForOvertimeAfterLeavingEarly"
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
                              region: "ca_on",
                              scheduled_shift: nil
                            },
                  current_weekly_hours: 0.0,
                  include_rules: [],
                  exclude_rules: [],
                  no_rules: false,
                  country: "ca", region: "on"
                }

    attr_reader :timesheet, :rules

    attr_accessor :current_weekly_hours, :current_daily_hours

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                        regular: 0.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})
      @timesheet = timesheet
      @options = DEFAULTS.merge(options.symbolize_keys)
      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]

      unless @options[:include_rules].empty?
        @rules = @options[:include_rules].select {|ir| DEFAULT_TIMESHEET_RULES.include?(ir) }
      else
        @rules = DEFAULT_TIMESHEET_RULES
      end

      @options[:exclude_rules].each {|er| @rules.reject!{|r| r == er }}

      @options[:criteria][:scheduled_shift] = timesheet.shift if timesheet.shift
    end

    def process_timesheet
      @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                                     current_daily_hours: @result_timesheet.total,
                                                                     left_early: @left_early,
                                                                     country: @options[:country],
                                                                     region: @options[:region] })

        if @options[:no_rules]
          base_rule.process_activity
        else
          activity_rules = DEFAULT_ACTIVITY_RULES.reject{|r| @options[:exclude_rules].include?(r) }

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

      base = Rules::Base.new(nil, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                          current_daily_hours: @result_timesheet.total,
                                                          left_early: @left_early,
                                                          country: @options[:country],
                                                          region: @options[:region],
                                                          processed_activity: @result_timesheet })

      @rules.each do |rule|
        get_clazz(rule).new(base).process_activity

        if base.stop
          break
        end
      end

      # if qualifies_for_minimum_after_leaving_early?
      #   # One scenario that isn't take care of is the below minimum but
      #   # partially on a holiday means 1 regular and 1 overtime hour.

      #   @result_timesheet[:minimum_regular] = @options[:criteria][:minimum_daily_hours]
      # elsif qualifies_for_overtime?
      #   @result_timesheet.overtime = (@result_timesheet.total - @result_timesheet.lunch) - @options[:criteria][:maximum_daily_hours]
      #   @result_timesheet.regular = @options[:criteria][:maximum_daily_hours]
      # end

      @result_timesheet
    end

    def get_clazz(rule)
      begin
        Object.const_get("Rules::#{rule}")
      rescue
        nil
      end
    end

    # def has_minimum_daily_hours?
    #   if rule_included?("MinimumDailyHours")
    #     Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}::MinimumDailyHours").check(
    #                         @result_timesheet.total,
    #                         @options[:criteria][:minimum_daily_hours])
    #   else
    #     true
    #   end
    # end

    # def has_maximum_daily_hours?
    #   rule_included?("MaximumDailyHours") ? Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}::MaximumDailyHours").check(@result_timesheet.total, @options[:criteria][:maximum_daily_hours]) : false
    # end

    # def qualifies_for_overtime?
    #   !@left_early && has_maximum_daily_hours?
    # end

    # def qualifies_for_minimum_after_leaving_early?
    #   !@left_early && !has_minimum_daily_hours? && @result_timesheet.overtime == 0.0
    # end

    # private

    # def rule_included?(rule)
    #   begin
    #     Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}::#{rule}").present? && @rules.include?(rule)
    #   rescue
    #     false
    #   end
    # end

  end
end