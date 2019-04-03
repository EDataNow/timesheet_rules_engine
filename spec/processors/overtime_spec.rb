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

      context 'overtime is paid' do
        context 'is an overtime activity type' do
          context 'when activity is lunch' do
            let(:context) { {current_weekly_hours: 40.0, current_daily_hours: 0.0} }

            it "should not calculate overtime at all under any circumstances" do
              base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-05 12:00pm"),
                                                            to: DateTime.parse("2019-04-05 1:00pm"))),
                                                            criteria, {current_weekly_hours: 40.0, current_daily_hours: 8.0})

              Overtime.new(base).calculate_hours

              expect(base.processed_activity.regular).to eq(-1.0)
              expect(base.processed_activity.overtime).to eq(0.0)
            end
          end

          let(:context) { {current_weekly_hours: 40.0, current_daily_hours: 0.0} }

          it "should calculate correct overtime hours from started on a regular day but ended on an overtime day while maxed out on daily hours" do
            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-05 9:00pm"),
                                                          to: DateTime.parse("2019-04-06 1:00am"))),
                                                          criteria, {current_weekly_hours: 40.0, current_daily_hours: 8.0})

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(0.0)
            expect(base.processed_activity.overtime).to eq(4.0)
          end

          it "should calculate correct overtime hours from started on a regular day but ended on an overtime day" do
            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-05 9:00pm"),
                                                          to: DateTime.parse("2019-04-06 1:00am"))),
                                                          criteria, context)

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(3.0)
            expect(base.processed_activity.overtime).to eq(1.0)
          end

          it "should calculate correct overtime hours on an overtime day" do
            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-07 9:00am"),
                                                          to: DateTime.parse("2019-04-07 1:00pm"))),
                                                          criteria, context)

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(0.0)
            expect(base.processed_activity.overtime).to eq(4.0)
          end

          it "should calculate correct overtime hours on a holiday" do
            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 5.0, from: DateTime.parse("2019-04-19 9:00am"),
                                                          to: DateTime.parse("2019-04-19 2:00pm"))),
                                                          criteria, context)

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(0.0)
            expect(base.processed_activity.overtime).to eq(5.0)
          end

          it "should calculate correct overtime hours on a regular day when current daily hours is the same as daily maximum" do
            context = {current_weekly_hours: 40.0, current_daily_hours: 8.0}

            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 2.0, from: DateTime.parse("2019-04-04 5:00pm"),
                                                          to: DateTime.parse("2019-04-04 7:00pm"))),
                                                          criteria, context)

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(0.0)
            expect(base.processed_activity.overtime).to eq(2.0)
          end

          it "should calculate correct overtime hours on a regular day when current daily hours is less than daily maximum but will go over with this activity" do
            context = {current_weekly_hours: 40.0, current_daily_hours: 7.0}

            base = Rules::Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-04 5:00pm"),
                                                          to: DateTime.parse("2019-04-04 7:00pm"))),
                                                          criteria, context)

            Overtime.new(base).calculate_hours

            expect(base.processed_activity.regular).to eq(1.0)
            expect(base.processed_activity.overtime).to eq(2.0)
          end
        end
      end
    end
  end
end