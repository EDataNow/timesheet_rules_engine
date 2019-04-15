Dir["lib/rules/**/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'byebug'
require 'active_support/all'
require 'ostruct'

module Processors
  class Timesheets
    DEFAULT_WEEKLY_RULES = [
                               "MinimumWeeklyHours"
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
                  country: "ca", region: "on"
                }

    attr_reader :processed_timesheets, :rules

    attr_accessor :current_weekly_hours

    def initialize(processed_timesheets, options)
      @options = DEFAULTS.merge(options.symbolize_keys)
      @result_timesheets = OpenStruct.new({billable: 0.0, downtime: 0.0, lunch: 0.0,
                                        regular: 0.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})

      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]

      unless @options[:include_rules].empty?
        @rules = @options[:include_rules]
      else
        @rules = DEFAULT_WEEKLY_RULES
      end

      @options[:exclude_rules].each {|er| @rules.reject!{|r| r == er }}

      if @options[:criteria][:scheduled_shift].nil?
        @options[:criteria][:scheduled_shift] = @options[:shift]
      end

      @processed_timesheets = processed_timesheets
    end

    def process_timesheets
      @processed_timesheets.each do |processed_timesheet|
        [:billable, :regular, :payable, :overtime, :minimum_regular, :downtime, :lunch, :total].each do |attribute|
          @result_timesheets[attribute] += processed_timesheet[attribute]
        end

        @result_timesheets[:regular] += processed_timesheet[:minimum_regular]
      end

      if qualifies_for_overtime_after_leaving_early?
        @result_timesheets[:overtime] = @result_timesheets[:overtime] - (@options[:criteria][:minimum_weekly_hours] - @result_timesheets[:regular])
        @result_timesheets[:regular] = @options[:criteria][:minimum_weekly_hours]
      elsif left_early_but_under_minimum?
        @result_timesheets[:regular] += @result_timesheets[:overtime]
        @result_timesheets[:overtime] = 0.0
      end

      @result_timesheets
    end

    private

    def left_early_but_under_minimum?
      @left_early && !has_minimum_weekly_hours?
    end

    def qualifies_for_overtime_after_leaving_early?
      @left_early && has_minimum_weekly_hours?
    end

    def has_minimum_weekly_hours?
      rule_included?("MinimumWeeklyHours") ? Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}::MinimumWeeklyHours").check(current_weekly_hours, @options[:criteria][:minimum_weekly_hours]) : true
    end

    def rule_included?(rule)
      begin
        Object.const_get("Rules::#{@options[:country].camelcase}::#{@options[:region].camelcase}::#{rule}").present? && @rules.include?(rule)
      rescue
        false
      end
    end
  end
end