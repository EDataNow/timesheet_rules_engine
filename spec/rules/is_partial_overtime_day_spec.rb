require 'rspec'
require 'rules/is_partial_overtime_day'

module Rules
  describe IsPartialOvertimeDay do
    describe 'processing by itself' do
      describe 'when there is no overtime' do
        let(:criteria) {
                          {
                              overtime_days: [],
                              saturdays_overtime: false,
                              sundays_overtime: false,
                              holidays_overtime: false,
                            }
                        }

        context 'when activity lands on a saturday' do
          let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-20 9:00am"),
                                                                      to: DateTime.parse("2019-04-20 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.regular).to eq(0.0)
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(0.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_partial_overtime_day).to be false
          end
        end

        context 'when activity lands on a holiday' do
          let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-19 9:00am"),
                                                                      to: DateTime.parse("2019-04-19 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.regular).to eq(0.0)
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(0.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_partial_overtime_day).to be false
          end
        end

        context 'when activity lands on a sunday' do
          let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-21 9:00am"),
                                                                      to: DateTime.parse("2019-04-21 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.regular).to eq(0.0)
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(0.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_partial_overtime_day).to be false
          end
        end
      end

      describe 'when there is a partial overtime' do
        context 'only on saturday' do
          let(:criteria) {
                          {
                              overtime_days: ["saturday"],
                              saturdays_overtime: true,
                              sundays_overtime: false,
                              holidays_overtime: false,
                            }
                        }

          context 'when activity starts on a saturday and ends on a sunday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-20 9:00pm"),
                                                                        to: DateTime.parse("2019-04-21 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.regular).to eq(1.0)
              expect(subject.overtime).to eq(3.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end

          context 'when activity starts on a friday and ends on a saturday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-19 9:00pm"),
                                                                        to: DateTime.parse("2019-04-20 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.regular).to eq(3.0)
              expect(subject.overtime).to eq(1.0)
              expect(subject.total).to eq(4.0)
            end

            it "should not be overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end
        end

        context 'only on sunday' do
          let(:criteria) {
                          {
                              overtime_days: ["sunday"],
                              saturdays_overtime: false,
                              sundays_overtime: true,
                              holidays_overtime: false,
                            }
                        }

          context 'when activity starts on a sunday and ends on a monday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-14 9:00pm"),
                                                                        to: DateTime.parse("2019-04-15 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.regular).to eq(1.0)
              expect(subject.overtime).to eq(3.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be partial overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end

          context 'when activity starts on a saturday and ends on a sunday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 6.0, from: DateTime.parse("2019-04-13 7:00pm"),
                                                                        to: DateTime.parse("2019-04-14 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.regular).to eq(5.0)
              expect(subject.overtime).to eq(1.0)
              expect(subject.total).to eq(6.0)
            end

            it "should have partial overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end
        end

        context 'only on holidays' do
          let(:criteria) {
                          {
                              overtime_days: [],
                              saturdays_overtime: false,
                              sundays_overtime: false,
                              holidays_overtime: true,
                            }
                        }

          context 'when activity starts on a holiday and ends on not a holiday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-19 9:00pm"),
                                                                        to: DateTime.parse("2019-04-20 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.regular).to eq(1.0)
              expect(subject.overtime).to eq(3.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end

          context 'when activity starts on a regular day and ends on a holiday' do
            let(:overtime_rule) { IsPartialOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-18 9:00pm"),
                                                                        to: DateTime.parse("2019-04-19 1:00am"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.regular).to eq(3.0)
              expect(subject.overtime).to eq(1.0)
              expect(subject.total).to eq(4.0)
            end

            it "should not be overtime" do
              expect(overtime_rule.is_partial_overtime_day).to be true
            end
          end
        end
      end
    end

    describe 'processing with a base' do
      let(:criteria) {
         {
            minimum_daily_hours: 0.0,
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
      }

      let(:base) { Base.new(OpenStruct.new(attributes_for(:activity, from: DateTime.parse("2019-04-07 9:00am"),
                                                                       to: DateTime.parse("2019-04-07 1:00pm"))), criteria) }
      let(:overtime_rule) { IsPartialOvertimeDay.new(base) }

      subject { overtime_rule.process_activity }

      it "should calculate billable, regular and total to be the same as total hours" do
        # expect(subject.id).to eq(1)
        # expect(subject.billable).to eq(0.0)
        # expect(subject.regular).to eq(0.0)
        # expect(subject.overtime).to eq(0.0)
        # expect(subject.total).to eq(0.0)
      end

    end
  end
end