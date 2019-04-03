require 'rspec'
require 'rules/is_downtime'

module Rules
  describe IsDowntime do
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

      context 'when activity is downtime' do
        let(:lunch) { IsDowntime.new(nil, OpenStruct.new(attributes_for(:activity, type: "downtime")), criteria) }
        subject { lunch.process_activity }

        it "should calculate downtime to be the same as total hours" do
          expect(subject.downtime).to eq(1.0)
          expect(subject.total).to eq(1.0)
        end
      end

      context 'when activity is not downtime' do
        let(:lunch) { IsDowntime.new(nil, OpenStruct.new(attributes_for(:activity)), criteria) }
        subject { lunch.process_activity }

        it "should not calculate downtime total to be the same as total hours" do
          expect(subject.downtime).to eq(0.0)
          expect(subject.total).to eq(1.0)
        end
      end


    end
  end
end