require 'rules/base'
require 'rules/is_overtime_day'
require 'ostruct'

module Processors
  class Timesheet
    DEFAULTS = { rules: ["IsOvertimeDay"], criteria: nil }

    attr_reader :timesheet

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0,
                                        regular: 0.0, overtime: 0.0, total: 0.0})
      @timesheet = timesheet
      @options = DEFAULTS.merge(options.symbolize_keys)
    end

    def process_timesheet
      @timesheet.activities.map do |activity|
        base_rule = BaseRule.new(activity, @options[:criteria])

        @options[:rules].each do |rule|
          rule.send(:new, base_rule).process_activity
        end

        base_rule.processed_activity
      end

      @result_timesheet
    end
  end
end