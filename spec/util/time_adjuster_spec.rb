require 'rspec'
require 'util/time_adjuster'
require 'date'

module Util
  describe TimeAdjuster do
    describe 'processing dates' do
      context "by rounding up the first 5 minutes to the nearest 0.25 of an hour" do
        it "should round up the from date to 10:00 if the time is 9:56 and the to date to 5:00 if the to date is 5:03" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:53am"), DateTime.parse("2018-01-01 5:03pm"), { closest_minute: 5 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 10:00am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:45 if the time is 9:49 and the to date to 5:30 if the to date is 5:25" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:49am"), DateTime.parse("2018-01-01 5:25pm"), { closest_minute: 5 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:45am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:30pm"))
        end
      end

      context "by rounding up the first 8 minutes to the nearest 0.20 of an hour" do
        it "should round up the from date to 10:24 if the time is 10:19 and the to date to 5:00 if the to date is 5:03" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 10:20am"), DateTime.parse("2018-01-01 5:03pm"), { billable_hour: 0.20 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 10:24am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:48 if the time is 9:55 and the to date to 5:36 if the to date is 5:32" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:55am"), DateTime.parse("2018-01-01 5:32pm"), { billable_hour: 0.20 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:48am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:36pm"))
        end
      end

      context "by rounding up the first 5 minutes to the nearest 0.20 of an hour" do
        it "should round up the from date to 10:12 if the time is 10:15 and the to date to 5:00 if the to date is 5:03" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 10:15am"), DateTime.parse("2018-01-01 5:03pm"), { billable_hour: 0.20, closest_minute: 5 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 10:12am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:48 if the time is 9:49 and the to date to 5:36 if the to date is 5:32" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:49am"), DateTime.parse("2018-01-01 5:32pm"), { billable_hour: 0.20, closest_minute: 5 })

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:48am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:36pm"))
        end
      end

      context "by rounding up the first 8 minutes to the nearest 0.25 of an hour" do
        it "should round down the from date to 9:00 if the time is 9:05" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:05am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:00am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:15 if the time is 9:08" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:08am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:15am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round down the from date to 9:15 if the time is 9:17" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:17am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:15am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:30 if the time is 9:25" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:25am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:30am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:30 if the time is 9:37" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:37am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:30am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:45 if the time is 9:40" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:40am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:45am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 9:45 if the time is 9:52" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:52am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 9:45am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 10:00 if the time is 9:53" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:53am"), DateTime.parse("2018-01-01 5:00pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 10:00am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:00pm"))
        end

        it "should round up the from date to 10:00 if the time is 9:53 and the to date to 5:30 if the to date is 5:25" do
          adjuster = TimeAdjuster.new(DateTime.parse("2018-01-01 9:53am"), DateTime.parse("2018-01-01 5:25pm"))

          expect(adjuster.process_dates.from).to eq(DateTime.parse("2018-01-01 10:00am"))
          expect(adjuster.process_dates.to).to eq(DateTime.parse("2018-01-01 5:30pm"))
        end
      end
    end
  end
end