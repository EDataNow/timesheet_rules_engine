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
                  closest_minute: 8.0,
                  scheduled_shift: nil,
                }

    attr_reader :activity, :criteria, :processed_activity

    attr_accessor :current_weekly_hours, :current_daily_hours, :left_early

    def initialize(activity, criteria={}, context={current_weekly_hours: 0.0, current_daily_hours: 0.0,
                                                   left_early: false, gets_bonus_overtime: true})
      @activity = activity
      @current_weekly_hours = context[:current_weekly_hours]
      @current_daily_hours = context[:current_daily_hours]
      @left_early = context[:left_early]

      @processed_activity = OpenStruct.new({id: activity.id, billable: 0.0,
                                            payable: 0.0, downtime: 0.0, lunch: 0.0, minimum_regular: 0.0,
                                            regular: 0.0, overtime: 0.0, total: activity.total_hours})

      @criteria = DEFAULTS.merge(criteria.symbolize_keys)
    end

    def process_activity
      @processed_activity[:billable] = @activity.total_hours
      @processed_activity[:payable] = @activity.total_hours
      @processed_activity[:regular] = @activity.total_hours

      @processed_activity
    end

    def check
      true
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