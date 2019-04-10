require 'rspec'
require 'rules/ca_on/minimum_weekly_hours'
require 'rules/base'

module Rules
  module CaOn
    describe MinimumWeeklyHours do
      describe 'processing' do
        context 'when activity is goes beyond minimum weekly hours' do
          subject {  MinimumWeeklyHours.check(41.0, 40.0) }

          it "should be beyond minimum weekly hours" do
            expect(subject).to be true
          end
        end

        context 'when activity is not over minimum weekly hours' do
          subject {  MinimumWeeklyHours.check(30.0, 40.0) }

          it "should not be beyond minimum weekly hours" do
            expect(subject).to be false
          end
        end


      end
    end
  end
end