require 'rules/base'
require 'processors/overtime'
Dir["rules/*.rb"].each {|file| require file }
require 'ostruct'
require 'byebug'

module Processors
  class Overtime
    DEFAULT_OVERTIME_RULES = [
                               'IsOvertimeDay',
                               'IsOvertimePaid',
                               'IsOvertimeActivityType',
                               "IsPartialOvertimeDay",
                               "MaximumDailyHours",
                               "MinimumWeeklyHours"
                             ]
    attr_reader :base, :rules

    def initialize(base, rules=[])
      @base = base
      @rules = rules.empty? ? DEFAULT_OVERTIME_RULES : rules
    end

    def calculate_hours
      @rules.each do |rule|
        "Rules::#{rule}".constantize.send(:new, base_rule).process_activity
      end
    end
  end
end