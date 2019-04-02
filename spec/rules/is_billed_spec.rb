require 'rspec'
require 'rules/is_billed'

module Rules
  describe IsBilled do
    describe 'processing' do
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
            closest_minute: 8.0,
            scheduled_shift: OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"),
                                            ended_at: DateTime.parse("2018-01-01 4:30pm"))
          }
      }

      context 'when activity is paid' do
        let(:billed) { IsBilled.new(nil, OpenStruct.new(attributes_for(:activity)), criteria) }
        subject { billed.process_activity }

        it "should calculate payable and total to be the same as total hours" do
          expect(subject.billable).to eq(1.0)
          expect(subject.total).to eq(1.0)
        end
      end

      context 'when activity is not paid' do
        let(:billed) { IsBilled.new(nil, OpenStruct.new(attributes_for(:activity, billed: false)), criteria) }
        subject { billed.process_activity }

        it "should not calculate payable and total to be the same as total hours" do
          expect(subject.billable).to eq(0.0)
          expect(subject.total).to eq(1.0)
        end
      end


    end
  end
end