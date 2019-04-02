require 'ostruct'
require 'byebug'

module Rules
  class Base
    DEFAULTS = {  minimum_daily_hours: 0.0,
                  maximum_daily_hours: 0.0,
                  minimum_weekly_hours: 0.0,
                  maximum_weekly_hours: 0.0,
                  overtime_days: ["saturday", "sunday"],
                  saturdays_overtime: true,
                  sundays_overtime: true,
                  holidays_overtime: true,
                  decimal_place: 2,
                  billable_hour: 0.25,
                  closest_minute: 8.0
                }

    attr_reader :activity, :criteria, :processed_activity

    attr_accessor :stop

    def initialize(activity, criteria={})
      @activity = activity
      @stop = false
      @processed_activity = OpenStruct.new({id: activity.id, billable: 0.0,
                                            payable: 0.0,
                                            regular: 0.0, overtime: 0.0, total: 0.0})

      @criteria = DEFAULTS.merge(criteria.symbolize_keys)
    end

    def process_activity
      @processed_activity[:billable] = @activity.total_hours
      @processed_activity[:payable] = @activity.total_hours
      @processed_activity[:regular] = @activity.total_hours
      @processed_activity[:total] = @activity.total_hours

      @processed_activity
    end

    def method_missing(method, *args)
      if @criteria.has_key?(method)
        @criteria[method]
      else
        super
      end
    end
  end
end