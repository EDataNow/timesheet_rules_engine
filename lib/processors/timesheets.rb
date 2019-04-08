require 'byebug'
require 'active_support/all'
Dir["lib/rules/*.rb"].each {|f| require f.gsub("lib/", "") }
require 'ostruct'

module Processors
  class Timesheets
    DEFAULT_WEEKLY_RULES = [
                               "MinimumWeeklyHours"
                             ]

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

    attr_reader :processed_timesheets, :rules, :gets_bonus_overtime

    attr_accessor :current_weekly_hours, :current_daily_hours, :total_overtime

    def initialize(processed_timesheets, options)
      @options = DEFAULTS.merge(options.symbolize_keys)
      @result_timesheets = OpenStruct.new({billable: 0.0, downtime: 0.0, lunch: 0.0,
                                        regular: 0.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})

      @current_weekly_hours = @options[:current_weekly_hours]
      @left_early = @options[:left_early]
      # @gets_bonus_overtime = @options[:gets_bonus_overtime]

      @options[:exclude_rules].each {|er| @options[:rules].reject!{|r| r == er }}
      unless @options[:include_rules].empty?
        @options[:rules] = @options[:include_rules]
      end

      # if @gets_bonus_overtime
      #   @options[:criteria][:minimum_weekly_hours] -= @options[:criteria][:overtime_reduction]
      # end

      if @options[:criteria][:scheduled_shift].nil?
        @options[:criteria][:scheduled_shift] = @options[:shift]
      end

      @processed_timesheets = processed_timesheets
      rules = @options[:rules]

      @rules = rules.empty? ? DEFAULT_WEEKLY_RULES : rules
    end

    def process_timesheets
      @processed_timesheets.each do |processed_timesheet|
        [:billable, :regular, :payable, :overtime, :downtime, :lunch, :total].each do |attribute|
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
      rule_included?("MinimumWeeklyHours") ? Rules::MinimumWeeklyHours.check(current_weekly_hours, @options[:criteria][:minimum_weekly_hours]) : true
    end

    def rule_included?(rule)
      @rules.include?(rule)
    end
  end
end