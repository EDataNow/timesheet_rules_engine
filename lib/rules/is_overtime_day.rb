module Rules
  class IsOvertimeDay < Base
    DEFAULTS = {  minimum_daily_hours: 0.0,
                  maximum_daily_hours: 0.0,
                  minimum_weekly_hours: 0.0,
                  maximum_weekly_hours: 0.0,
                  saturdays_overtime: true,
                  sundays_overtime: true,
                  holidays_overtime: true,
                  decimal_place: 2,
                  billable_hour: 0.25,
                  closest_minute: 8.0
                }

    attr_reader :criteria, :activity, :processed_activity

    def initialize(base=nil, activity=nil, criteria)
      if base
        @activity = base.activity
        @criteria = base.criteria
        @process_activity = base.processed_activity
      else
        @activity = activity
        @processed_activity = OpenStruct.new({id: activity.id, billable: 0.0,
                                          regular: 0.0, overtime: 0.0, total: 0.0})
        @criteria = DEFAULTS.merge(criteria.symbolize_keys)
      end
    end

    def process_activity
      @processed_activity
    end
  end
end