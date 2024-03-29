require 'rspec'
require 'rules/is_overtime_day'

module Rules
  describe IsOvertimeDay do
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
          let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-20 9:00am"),
                                                                      to: DateTime.parse("2019-04-20 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(4.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_overtime_day).to be false
          end
        end

        context 'when activity lands on a holiday' do
          let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-19 9:00am"),
                                                                      to: DateTime.parse("2019-04-19 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(4.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_overtime_day).to be false
          end
        end

        context 'when activity lands on a sunday' do
          let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-21 9:00am"),
                                                                      to: DateTime.parse("2019-04-21 1:00pm"))), criteria) }

          subject { overtime_rule.process_activity }

          it "should not have all hours in overtime" do
            expect(subject.overtime).to eq(0.0)
            expect(subject.total).to eq(4.0)
          end

          it "should not be overtime" do
            expect(overtime_rule.is_overtime_day).to be false
          end
        end
      end

      describe 'when there is overtime' do
        context 'only on saturday' do
          let(:criteria) {
                          {
                              overtime_days: ["saturday"],
                              saturdays_overtime: true,
                              sundays_overtime: false,
                              holidays_overtime: false,
                            }
                        }

          context 'when activity lands on a saturday' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-20 9:00am"),
                                                                        to: DateTime.parse("2019-04-20 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.overtime).to eq(4.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be overtime" do
              expect(overtime_rule.is_overtime_day).to be true
            end
          end

          context 'when activity lands on a sunday' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-21 9:00am"),
                                                                        to: DateTime.parse("2019-04-21 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.overtime).to eq(0.0)
              expect(subject.total).to eq(4.0)
            end

            it "should not be overtime" do
              expect(overtime_rule.is_overtime_day).to be false
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

          context 'when activity lands on a sunday' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-14 9:00am"),
                                                                        to: DateTime.parse("2019-04-14 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.overtime).to eq(4.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be overtime" do
              expect(overtime_rule.is_overtime_day).to be true
            end
          end

          context 'when activity lands on a saturday' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-13 9:00am"),
                                                                        to: DateTime.parse("2019-04-13 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.overtime).to eq(0.0)
              expect(subject.total).to eq(4.0)
            end

            it "should not be overtime" do
              expect(overtime_rule.is_overtime_day).to be false
            end
          end
        end

        context 'on weekends and holidays' do
          let(:criteria) {
                          {
                              overtime_days: ["saturday", "sunday"],
                              saturdays_overtime: true,
                              sundays_overtime: true,
                              holidays_overtime: true,
                            }
                        }

          context 'when activity lands on a weekend' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-07 9:00am"),
                                                                        to: DateTime.parse("2019-04-07 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should have all hours in overtime" do
              expect(subject.overtime).to eq(4.0)
              expect(subject.total).to eq(4.0)
            end

            it "should be overtime" do
              expect(overtime_rule.is_overtime_day).to be true
            end
          end

          context 'when activity does not land on a weekend' do
            let(:overtime_rule) { IsOvertimeDay.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 9:00am"),
                                                                        to: DateTime.parse("2019-04-08 1:00pm"))), criteria) }

            subject { overtime_rule.process_activity }

            it "should not have all hours in overtime" do
              expect(subject.overtime).to eq(0.0)
              expect(subject.total).to eq(4.0)
            end

            it "should not be overtime" do
              expect(overtime_rule.is_overtime_day).to be false
            end
          end
        end
      end
    end
  end
end