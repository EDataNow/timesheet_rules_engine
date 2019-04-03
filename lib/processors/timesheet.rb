require 'rules/base'
Dir["rules/*.rb"].each {|file| require file }
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
    DEFAULTS = { rules: [
                          "IsOvertimeDay",
                          'IsPartialOvertimeDay',
                          'IsPaid',
                          "isOvertimePaid",
                          "isBilled"
                        ], criteria: nil, current_weekly_hours: 0.0,
                           include_rules: [], exclude_rules: [], left_early: false, gets_bonus_overtime: true }

    attr_reader :timesheet, :rules

    attr_accessor :current_weekly_hours, :current_daily_hours

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0, downtime: 0.0,
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

      if @options[:criteria][:scheduled_shift].nil?
        @options[:criteria][:scheduled_shift] = timesheet.shift
      end
    end

    def process_timesheet
      @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria], { current_weekly_hours: @current_weekly_hours,
                                                                     current_daily_hours: @result_timesheet.total,
                                                                     left_early: @left_early,
                                                                     gets_bonus_overtime: @gets_bonus_overtime })

        if @options[:rules].empty?
          base_rule.process_activity
        else
          @options[:rules].each do |rule|
            "Rules::#{rule}".constantize.send(:new, base_rule).process_activity

            # if base_rule.stop
            #   break
            # end
          end
        end

        [:billable, :regular, :payable, :overtime, :downtime, :total].each do |attribute|
          @result_timesheet[attribute] += base_rule.processed_activity[attribute]
        end

        base_rule.processed_activity
      end

      @result_timesheet
    end
  end
end