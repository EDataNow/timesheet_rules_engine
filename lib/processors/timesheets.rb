# Dir["lib/rules/**/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'active_support/all'
require 'ostruct'

module Processors
  class Timesheets
    DEFAULT_WEEKLY_RULES = [
                               "Incentive::QualifiesForWeeklyOvertimeAfterLeavingEarly",
                               "Incentive::LeftEarlyButUnderMinimumWeekly"
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
                              scheduled_shift: nil,
                            },
                  current_weekly_hours: 0.0,
                  include_rules: [],
                  exclude_rules: [],
                  left_early: false,
                  exclude_incentive_rules: false,
                  country: "ca", region: "on"
                }

    attr_reader :processed_timesheets, :rules

    attr_accessor :current_weekly_hours

    def initialize(processed_timesheets, options)
      @options = DEFAULTS.merge(options.symbolize_keys)
      @result_timesheets = OpenStruct.new({billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 0.0, raw_regular: 0.0,
                                        regular: 0.0, minimum_regular: 0.0, payable: 0.0, raw_overtime: 0.0, overtime: 0.0, total: 0.0})

      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]

      unless @options[:include_rules].empty?
        @rules = @options[:include_rules].select {|ir| DEFAULT_WEEKLY_RULES.include?(ir) }
      else
        @rules = DEFAULT_WEEKLY_RULES
      end

      @options[:exclude_rules].each {|er| @rules.reject!{|r| r == er }}

      if @options[:exclude_incentive_rules]
        @rules = []
      end

      @processed_timesheets = processed_timesheets
    end

    def process_timesheets
      @processed_timesheets.each do |processed_timesheet|
        [:billable, :raw_regular, :regular, :payable, :raw_overtime, :overtime, :minimum_regular, :raw_downtime, :downtime, :lunch, :total].each do |attribute|
          @result_timesheets[attribute] += processed_timesheet[attribute]
        end

        if processed_timesheet[:minimum_regular] > 0
          @result_timesheets[:regular] += processed_timesheet[:minimum_regular]
          @result_timesheets[:regular] -= processed_timesheet[:regular]
          @result_timesheets[:total] -= processed_timesheet[:regular]
          @result_timesheets[:total] += processed_timesheet[:minimum_regular]
          @result_timesheets[:raw_regular] = @result_timesheets[:regular] * 3600.0
        end
      end

      base = ::Rules::Base.new(nil, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                          left_early: @left_early,
                                                          country: @options[:country],
                                                          region: @options[:region],
                                                          processed_activity: @result_timesheets })

      @rules.each do |rule|
        get_clazz(rule).new(base).process_activity

        break if base.stop
      end

      @result_timesheets
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