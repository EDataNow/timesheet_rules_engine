require 'rspec'
require 'rules/ca/on/is_holiday'

module Rules
  module Ca
    module On
      describe IsHoliday do
        describe 'processing by itself' do
          describe 'when there is no overtime' do
            let(:criteria) {
                              {
                                holidays_overtime: true
                              }
                            }

            context 'when activity lands on a holiday' do
              let(:overtime_rule) { IsHoliday.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-19 9:00am"),
                                                                          to: DateTime.parse("2019-04-19 1:00pm"))), criteria) }

              subject { overtime_rule.process_activity }

              it "should have all hours in overtime" do
                expect(subject.overtime).to eq(4.0)
                expect(subject.total).to eq(4.0)
              end

              it "should be overtime" do
                expect(overtime_rule.check).to be true
              end
            end

            context 'when activity does not land on a holiday' do
              let(:overtime_rule) { IsHoliday.new(nil, OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-18 9:00am"),
                                                                          to: DateTime.parse("2019-04-18 1:00pm"))), criteria) }

              subject { overtime_rule.process_activity }

              it "should not have all hours in overtime" do
                expect(subject.overtime).to eq(0.0)
                expect(subject.total).to eq(4.0)
              end

              it "should not be overtime" do
                expect(overtime_rule.check).to be false
              end
            end
          end
        end
      end
    end
  end
end