require 'rspec'
require 'ostruct'
require 'processors/overtime'
require 'rules/base'

module Processors
  describe Overtime do
    describe 'all default rules' do
      let(:criteria) {
                      {
                          minimum_daily_hours: 3.0,
                          maximum_daily_hours: 8.0,
                          minimum_weekly_hours: 40.0,
                          maximum_weekly_hours: 60.0,
                          saturdays_overtime: true,
                          sundays_overtime: true,
                          holidays_overtime: true,
                          decimal_place: 2,
                          billable_hour: 0.25,
                          closest_minute: 8.0,
                          overtime_reduction: 0.0
                        }
                      }

      context 'did not leave early, arrive late, worked all scheduled shifts and scheduled hours' do
        context 'overtime is paid' do
          context 'worked minimum weekly hours' do
            let(:context) { {current_weekly_hours: 40.0, current_daily_hours: 0.0} }

            it "should calculate correct overtime hours on an overtime day" do
              base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-07 9:00am"),
                                                            to: DateTime.parse("2019-04-07 1:00pm"))),
                                                            criteria, context)

              Overtime.new(base).calculate_hours

              expect(base.processed_activity.overtime).to eq(4.0)
            end

            it "should calculate correct overtime hours on a holiday" do
              base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 5.0, from: DateTime.parse("2019-04-19 9:00am"),
                                                            to: DateTime.parse("2019-04-19 2:00pm"))),
                                                            criteria, context)

              Overtime.new(base).calculate_hours

              expect(base.processed_activity.overtime).to eq(5.0)
            end


          end
        end
      end
    end
  end
end