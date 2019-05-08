require 'ostruct'
require 'date'
require 'active_support/all'

module Util
  class TimeAdjuster
    DEFAULTS = {
                  billable_hour: 0.25,
                  closest_minute: 8.0,
                  decimal_place: 2.0
               }

    def initialize(from, to, options={})
      @from = from
      @to = to

      @options = DEFAULTS.merge(options.symbolize_keys)

      @seconds = (60 * billable_hour) * 60
    end

    def process_dates
      new_from = process_date(@from)
      new_to = process_date(@to)

      OpenStruct.new({from: new_from, to: new_to})
    end

    def hours_difference
      new_dates = process_dates
      ((new_dates.to.to_i - new_dates.from.to_i) / 3600.0).round(decimal_place.to_f)
    end

    def method_missing(method, *args)
      if @options.has_key?(method)
        @options[method]
      else
        super
      end
    end

    private

    def process_date(date)
      adjustment = calculate_round_down_difference(date)

      if adjustment < closest_minute
        date = date.advance(minutes: adjustment * -1)
      else
        date = date.advance(minutes: calculate_round_up_difference(date))
      end

      date
    end

    def calculate_round_up_difference(date_time)
      rounded_up = ceil_time_for_seconds(date_time)

      ((rounded_up.to_f - date_time.to_f) / 60).round
    end

    def calculate_round_down_difference(date_time)
      rounded_down = floor_time_for_seconds(date_time)

      ((date_time.to_f - rounded_down.to_f) / 60).round
    end

    def ceil_time_for_seconds(date_time)
      Time.at((date_time.to_f / @seconds).ceil * @seconds)
    end

    def floor_time_for_seconds(date_time)
      Time.at((date_time.to_f / @seconds).floor * @seconds)
    end
  end
end