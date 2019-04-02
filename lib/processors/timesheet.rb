require 'rules/base'
Dir["rules/*.rb"].each {|file| require file }
require 'ostruct'
require 'byebug'

module Processors
  class Timesheet
    DEFAULTS = { rules: ["IsOvertimeDay", 'IsPartialOvertimeDay'], criteria: nil }

    attr_reader :timesheet, :rules

    def initialize(timesheet, options={})
      @result_timesheet = OpenStruct.new({id: timesheet.id, billable: 0.0,
                                        regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0})
      @timesheet = timesheet
      @options = DEFAULTS.merge(options.symbolize_keys)
    end

    def process_timesheet
      @timesheet.activities.map do |activity|
        base_rule = Rules::Base.new(activity, @options[:criteria])

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

        [:billable, :regular, :payable, :overtime, :total].each do |attribute|
          @result_timesheet[attribute] += base_rule.processed_activity[attribute]
        end

        base_rule.processed_activity
      end

      @result_timesheet
    end
  end
end