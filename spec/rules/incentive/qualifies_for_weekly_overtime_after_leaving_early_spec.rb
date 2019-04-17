require 'rspec'
require 'rules/incentive/qualifies_for_weekly_overtime_after_leaving_early'
require 'rules/base'

module Rules
  module Incentive
    describe QualifiesForWeeklyOvertimeAfterLeavingEarly do
      describe 'processing' do
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
              scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                              ended_at: DateTime.parse("2018-01-01 4:30pm"))
            }
        }

        context 'did leave early' do
          context 'when activity is goes beyond minimum weekly hours' do
            let(:processed_activity) { OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                          regular: 35.0, minimum_regular: 0.0, payable: 0.0, overtime: 26.0, total: 0.0}) }

            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 61.0, left_early: true,
                                                                                                          current_daily_hours: 40.0, processed_activity: processed_activity}) }
            subject { QualifiesForWeeklyOvertimeAfterLeavingEarly.new(base) }

            it "should be beyond minimum daily hours" do
              subject.process_activity

              expect(subject.processed_activity.regular).to eq(44.0)
              expect(subject.processed_activity.overtime).to eq(17.0)
              expect(subject.check).to be true
            end
          end

          context 'when activity is not over minimum daily hours' do
            let(:processed_activity) { OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                          regular: 1.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}) }

            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 1.0, left_early: true,
                                                                                                          current_daily_hours: 1.0, processed_activity: processed_activity}) }
            subject { QualifiesForWeeklyOvertimeAfterLeavingEarly.new(base) }

            it "should not be beyond minimum daily hours" do
              subject.process_activity

              expect(subject.check).to be false
              expect(subject.processed_activity.regular).to eq(1.0)
            end
          end
        end

        context 'did not leave early' do
          context 'when activity is goes beyond minimum daily hours' do
            let(:processed_activity) { OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                          regular: 0.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}) }

            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 61.0, left_early: false,
                                                                                                          current_daily_hours: 40.0, processed_activity: processed_activity}) }
            subject { QualifiesForWeeklyOvertimeAfterLeavingEarly.new(base) }

            it "should be beyond minimum daily hours" do
              subject.process_activity

              expect(subject.processed_activity.regular).to eq(0.0)
              expect(subject.check).to be false
            end
          end

          context 'when activity is not over minimum daily hours' do
            let(:processed_activity) { OpenStruct.new({id: 1, billable: 0.0, downtime: 0.0, lunch: 0.0,
                                          regular: 1.0, minimum_regular: 0.0, payable: 0.0, overtime: 0.0, total: 0.0}) }

            let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, total_hours: 4.0)), criteria, {current_weekly_hours: 61.0, left_early: false,
                                                                                                          current_daily_hours: 1.0, processed_activity: processed_activity}) }
            subject { QualifiesForWeeklyOvertimeAfterLeavingEarly.new(base) }

            it "should not be beyond minimum daily hours" do
              subject.process_activity

              expect(subject.check).to be false
              expect(subject.processed_activity.regular).to eq(1.0)
            end
          end
        end


      end
    end
  end
end