Dir["lib/rules/**/**/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'processors/activity'
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
    DEFAULT_ACTIVITY_RULES = [
                               'IsOvertimeDay',
                               'IsLunch',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                              #  "Ca::On::IsPartialOvertimeDay",
                              #  'Ca::On::IsHoliday'
                             ]

    DEFAULT_TIMESHEET_RULES =  [
                                'Incentive::QualifiesForMinimumAfterLeavingEarly',
                                "Incentive::QualifiesForDailyOvertimeAfterLeavingEarly"
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
      process_activities

      base = Rules::Base.new(nil, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                          current_daily_hours: @result_timesheet.total,
                                                          left_early: @left_early,
                                                          country: @options[:country],
                                                          region: @options[:region],
                                                          processed_activity: @result_timesheet })

      @rules.each do |rule|
        get_clazz(rule).new(base).process_activity

        break if base.stop
      end

      @result_timesheet
    end

    def process_activities
      @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                                     current_daily_hours: @result_timesheet.total,
                                                                     left_early: @left_early,
                                                                     country: @options[:country],
                                                                     region: @options[:region] })

        if @options[:no_rules]
          base_rule.process_activity
        else
          activity_rules = DEFAULT_ACTIVITY_RULES + regional_activity_rules
          activity_rules = activity_rules.reject{|r| @options[:exclude_rules].include?(r) }

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
    end

    private

    def regional_activity_rules
      begin
        Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}").constants.map do |clazz|
          "#{@options[:country].camelcase}::#{@options[:region].camelcase}::#{clazz.to_s}"
        end
      rescue
        puts "THERE ARE NO RULES FOR THIS COUNTRY / REGION"
        []
      end
    end

    def get_clazz(rule)
      begin
        Object.const_get("Rules::#{rule}")
      rescue
        nil
      end
    end

  end
end