require 'ostruct'

module Rules
  class Base
    DEFAULTS = {
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
                  scheduled_shift: nil
                }

    attr_reader :activity, :criteria, :processed_activity, :country, :region, :full_region

    attr_accessor :current_weekly_hours, :current_daily_hours, :left_early, :stop

    def initialize(activity, criteria={}, context={current_weekly_hours: 0.0, current_daily_hours: 0.0,
                                                   left_early: false, region: "on", country: "ca", processed_activity: nil})
      @activity = activity
      @stop = false
      @current_weekly_hours = context[:current_weekly_hours]
      @current_daily_hours = context[:current_daily_hours]
      @left_early = context[:left_early]
      @country = context[:country]
      @region = context[:region]
      @full_region = "#{@country}_#{@region}"

      if context[:processed_activity]
        @processed_activity = context[:processed_activity]
      else
        @processed_activity = OpenStruct.new({id: activity.id, billable: 0.0,
                                              payable: 0.0, downtime: 0.0, lunch: 0.0, minimum_regular: 0.0,
                                              raw_downtime: 0.0, raw_regular: 0.0, raw_overtime: 0.0,
                                              regular: 0.0, overtime: 0.0, total: activity.total_hours})
      end

      @criteria = DEFAULTS.merge(criteria.symbolize_keys)
    end

    def process_activity
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