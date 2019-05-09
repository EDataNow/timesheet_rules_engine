require 'rspec'
require 'ostruct'
require 'processors/timesheets'

module Processors
  describe Timesheets do
    let(:criteria) {
         {
            minimum_daily_hours: 3.0,
            maximum_daily_hours: 8.0,
            minimum_weekly_hours: 44.0,
            maximum_weekly_hours: 60.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-04 7:00am"),
                                ended_at: DateTime.parse("2019-04-04 3:00pm"))
          }
      }

    describe 'rules and activities' do
      context 'left early one day of the week' do
        let(:criteria) {
         {
            minimum_daily_hours: 3.0,
            maximum_daily_hours: 8.0,
            minimum_weekly_hours: 44.0,
            maximum_weekly_hours: 60.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-06 7:00am"),
                                ended_at: DateTime.parse("2019-04-06 3:00pm"))
          }
        }

        context 'did go over the weekly minimum limit' do
          it "should calculate correct regular and overtime hours when the user worked overtime on a couple of scheduled days" do
            processed_timesheets = [
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 0.0, overtime: 0.0, total: 8.0}),
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 8.0, raw_regular: 28880.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 0.0, overtime: 1.0, total: 10.0}),
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 0.0, overtime: 0.0, total: 8.0}),
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 0.0, overtime: 0.0, total: 8.0}),
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 10800.0, overtime: 3.0, total: 11.0}),
              OpenStruct.new({id: 1, billable: 0.0, raw_downtime: 0.0, downtime: 0.0, lunch: 1.0, regular: 0.0, raw_regular: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, raw_overtime: 32400.0, overtime: 9.0, total: 10.0}),
            ]

            result = Timesheets.new(processed_timesheets, {criteria: criteria, left_early: true, current_weekly_hours: 55.0}).process_timesheets

            expect(result.regular).to eq(44.0)
            expect(result.overtime).to eq(5.0)
          end
        end
        context 'did not go over the weekly minimum limit' do
          it "should calculate correct regular and overtime hours when the user worked overtime on a couple of scheduled days" do
            processed_timesheets = [
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
              OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 0.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                      minimum_regular: 0.0, payable: 0.0, overtime: 3.0, total: 0.0})
            ]

            result = Timesheets.new(processed_timesheets, {criteria: criteria, left_early: true, current_weekly_hours: 38.0}).process_timesheets

            expect(result.regular).to eq(38.0)
            expect(result.overtime).to eq(0.0)
          end
        end
      end
      context 'worked all scheduled days and hours' do
        let(:criteria) {
         {
            minimum_daily_hours: 3.0,
            maximum_daily_hours: 8.0,
            minimum_weekly_hours: 44.0,
            maximum_weekly_hours: 60.0,
            saturdays_overtime: true,
            sundays_overtime: true,
            holidays_overtime: true,
            decimal_place: 2,
            billable_hour: 0.25,
            closest_minute: 8.0,
            region: "ca_on",
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2019-04-06 7:00am"),
                                ended_at: DateTime.parse("2019-04-06 3:00pm"))
          }
        }

        it "should calculate correct regular and overtime hours when left early for legit reason during the week" do
          processed_timesheets = [
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 9.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 1.0, total: 11.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0, regular: 1.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 3.0, payable: 0.0, overtime: 0.0, total: 1.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
          ]

          result = Timesheets.new(processed_timesheets, {criteria: criteria}).process_timesheets

          expect(result.regular).to eq(33.0)
          expect(result.overtime).to eq(1.0)
        end

        it "should calculate correct regular and overtime hours when left early for non legit reason during the week" do
          processed_timesheets = [
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 9.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 1.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0, regular: 1.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
          ]

          result = Timesheets.new(processed_timesheets, {criteria: criteria, left_early: true}).process_timesheets

          expect(result.regular).to eq(32.0)
          expect(result.overtime).to eq(0.0)
        end

        it "should calculate correct regular and overtime hours when the user worked overtime on a couple of scheduled days" do
          processed_timesheets = [
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 2.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 8.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 3.0, total: 8.0}),
          ]

          result = Timesheets.new(processed_timesheets, {criteria: criteria}).process_timesheets

          expect(result.regular).to eq(35.0)
          expect(result.overtime).to eq(5.0)
        end

        it "should calculate correct regular and overtime hours when the user worked overtime on the weekend" do
          processed_timesheets = [
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 0.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 3.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 0.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 3.0, total: 0.0}),
          ]

          result = Timesheets.new(processed_timesheets, {criteria: criteria}).process_timesheets

          expect(result.regular).to eq(35.0)
          expect(result.overtime).to eq(6.0)
        end

        it "should calculate all hours to be regular when no overtime logged" do
          processed_timesheets = [
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
            OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 1.0, regular: 7.0, raw_regular: 25200.0, raw_overtime: 0.0, raw_downtime: 0.0,
                                    minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}),
          ]

          result = Timesheets.new(processed_timesheets, {criteria: criteria}).process_timesheets

          expect(result.regular).to eq(35.0)
          expect(result.overtime).to eq(0.0)
        end
      end
    end
  end
end