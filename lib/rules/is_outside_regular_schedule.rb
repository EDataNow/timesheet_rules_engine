require 'rules/base'
require 'util/time_adjuster'
require 'byebug'

module Rules
  class IsOutsideRegularSchedule < Base
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
                  scheduled_shift: nil
                }

    attr_reader :criteria, :activity, :processed_activity, :base

    def initialize(base, activity=nil, criteria=nil)
      if base
        @activity = base.activity
        @criteria = base.criteria
        @processed_activity = base.processed_activity
        @partial_overtime_time_field = nil
        @base = base
      else
        super(activity, criteria)
      end

      new_dates = Util::TimeAdjuster.new(@activity.from, @activity.to).process_dates

      @from = new_dates.from
      @to = new_dates.to
      assign_partial_field
    end

    def check
      !@partial_overtime_time_field.nil?
    end

    def calculate_hours
      started_at = scheduled_shift.started_at
      ended_at = scheduled_shift.ended_at

      if @partial_overtime_time_field == "both_started_at"
        @processed_activity[:overtime] = @activity.total_hours
      elsif @partial_overtime_time_field == "from_started_at"
        @processed_activity[:regular] = ((@to.to_i - started_at.to_i) / 3600.0).round(decimal_place)
        @processed_activity[:overtime] = ((started_at.to_i - @from.to_i) / 3600.0).round(decimal_place)
      elsif @partial_overtime_time_field == "both_ended_at"
        @processed_activity[:overtime] = @activity.total_hours
      elsif @partial_overtime_time_field == "to_ended_at"
        @processed_activity[:regular] = ((ended_at.to_i - @from.to_i) / 3600.0).round(decimal_place)
        @processed_activity[:overtime] = ((@to.to_i - ended_at.to_i) / 3600.0).round(decimal_place)
      else
        @processed_activity[:regular] = @activity.total_hours
      end
    end

    def process_activity
      calculate_hours if check

      @processed_activity
    end

    private

    def assign_partial_field
      started_at = scheduled_shift.started_at
      ended_at = scheduled_shift.ended_at

      if @to < started_at
        @partial_overtime_time_field = "both_started_at"
      elsif @from < started_at
        @partial_overtime_time_field = "from_started_at"
      elsif @from > ended_at
        @partial_overtime_time_field = "both_ended_at"
      elsif @to > ended_at
        @partial_overtime_time_field = "to_ended_at"
      end
    end
  end
end