require 'rspec'
require 'ostruct'
require 'timesheet_rules_engine'

describe TimesheetRulesEngine do
  context 'only use is lunch rule' do
    context 'worked all only on a saturday' do
      let(:saturday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-13 7:00am"),
                                                              to: DateTime.parse("2019-04-13 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-13 11:00am"),
                                                              to: DateTime.parse("2019-04-13 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-13 12:00pm"),
                                                              to: DateTime.parse("2019-04-13 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: saturday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-13 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-13 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets, { include_rules: ["IsLunch"] }).process_timesheets

        expect(result.regular).to eq(7.0)
        expect(result.overtime).to eq(0.0)
      end
    end
  end

  context 'removing is lunch rule' do
    context 'worked all scheduled hours and days' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-09 7:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-10 11:00am"),
                                                              to: DateTime.parse("2019-04-10 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-10 12:00pm"),
                                                              to: DateTime.parse("2019-04-10 3:00pm")))
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets, { exclude_rules: ["IsLunch"] }).process_timesheets

        expect(result.regular).to eq(40.0)
        expect(result.overtime).to eq(0.0)
      end
    end
  end

  context 'standard criteria and shift' do
    let(:criteria) {
          {
              minimum_daily_hours: 3.0,
              maximum_daily_hours: 8.0,
              minimum_weekly_hours: 44.0,
              maximum_weekly_hours: 60.0,
              overtime_days: ["saturday", "sunday"],
              saturdays_overtime: true,
              sundays_overtime: true,
              holidays_overtime: true,
              decimal_place: 2,
              billable_hour: 0.25,
              closest_minute: 8.0,
              region: "on_ca"
            }
        }

    context 'worked scheduled days but worked some overtime on tuesday and saturday and left early on wednesday for a non-legit reason' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 6.0, from: DateTime.parse("2019-04-09 5:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-10 11:00am"),
                                                              to: DateTime.parse("2019-04-10 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-10 12:00pm"),
                                                              to: DateTime.parse("2019-04-10 3:00pm")))
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:saturday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-13 5:00am"),
                                                              to: DateTime.parse("2019-04-13 9:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-13 9:00am"),
                                                              to: DateTime.parse("2019-04-13 10:00am"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 5.0, from: DateTime.parse("2019-04-13 10:00am"),
                                                              to: DateTime.parse("2019-04-13 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 6:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday, left_early: true,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 6:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: saturday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-13 5:00am"),
                                                              ended_at: DateTime.parse("2019-04-13 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets).process_timesheets

        expect(result.overtime).to eq(2.0)
        expect(result.regular).to eq(44.0)
      end
    end

    context 'worked scheduled days but worked some overtime on tuesday and left early on wednesday for a legit reason' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 7.0, from: DateTime.parse("2019-04-09 4:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 1.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 8:00am"))),
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 5:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets).process_timesheets

        expect(result.overtime).to eq(2.0)
        expect(result.regular).to eq(32.0)
      end
    end

    context 'worked scheduled days but worked some overtime on tuesday and left early on wednesday for a non-legit reason' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 7.0, from: DateTime.parse("2019-04-09 4:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 1.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 8:00am"))),
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 5:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday, left_early: true,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets).process_timesheets

        expect(result.overtime).to eq(0.0)
        expect(result.regular).to eq(32.0)
      end
    end

    context 'worked all scheduled hours and days and overtime on the weekend' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-09 7:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-10 11:00am"),
                                                              to: DateTime.parse("2019-04-10 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-10 12:00pm"),
                                                              to: DateTime.parse("2019-04-10 3:00pm")))
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:saturday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 2.0, from: DateTime.parse("2019-04-13 7:00am"),
                                                              to: DateTime.parse("2019-04-13 9:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-13 9:00am"),
                                                              to: DateTime.parse("2019-04-13 10:00am"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 1.0, from: DateTime.parse("2019-04-13 10:00am"),
                                                              to: DateTime.parse("2019-04-13 11:00am")))
        ]
      }

      let(:sunday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 1.0, from: DateTime.parse("2019-04-14 3:00pm"),
                                                              to: DateTime.parse("2019-04-14 4:00pm"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-14 4:00pm"),
                                                              to: DateTime.parse("2019-04-14 5:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 2.0, from: DateTime.parse("2019-04-14 5:00pm"),
                                                              to: DateTime.parse("2019-04-14 7:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: saturday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-13 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-13 11:00am")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: sunday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-14 3:00pm"),
                                                              ended_at: DateTime.parse("2019-04-14 7:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets).process_timesheets

        expect(result.regular).to eq(35.0)
        expect(result.overtime).to eq(6.0)
      end
    end

    context 'worked all scheduled hours and days' do
      let(:monday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-08 7:00am"),
                                                              to: DateTime.parse("2019-04-08 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-08 11:00am"),
                                                              to: DateTime.parse("2019-04-08 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-08 12:00pm"),
                                                              to: DateTime.parse("2019-04-08 3:00pm")))
        ]
      }

      let(:tuesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-09 7:00am"),
                                                              to: DateTime.parse("2019-04-09 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-09 11:00am"),
                                                              to: DateTime.parse("2019-04-09 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-09 12:00pm"),
                                                              to: DateTime.parse("2019-04-09 3:00pm")))
        ]
      }

      let(:wednesday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-10 7:00am"),
                                                              to: DateTime.parse("2019-04-10 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-10 11:00am"),
                                                              to: DateTime.parse("2019-04-10 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-10 12:00pm"),
                                                              to: DateTime.parse("2019-04-10 3:00pm")))
        ]
      }

      let(:thursday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-11 7:00am"),
                                                              to: DateTime.parse("2019-04-11 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-11 11:00am"),
                                                              to: DateTime.parse("2019-04-11 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-11 12:00pm"),
                                                              to: DateTime.parse("2019-04-11 3:00pm")))
        ]
      }

      let(:friday) {
        [
          OpenStruct.new(attributes_for(:activity, total_hours: 4.0, from: DateTime.parse("2019-04-12 7:00am"),
                                                              to: DateTime.parse("2019-04-12 11:00am"))),
          OpenStruct.new(attributes_for(:activity, type: "lunch", total_hours: 1.0, from: DateTime.parse("2019-04-12 11:00am"),
                                                              to: DateTime.parse("2019-04-12 12:00pm"))),
          OpenStruct.new(attributes_for(:activity, total_hours: 3.0, from: DateTime.parse("2019-04-12 12:00pm"),
                                                              to: DateTime.parse("2019-04-12 3:00pm")))
        ]
      }

      let(:timesheets) {
        [
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: monday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-08 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-08 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: tuesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-09 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-09 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: wednesday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-10 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-10 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: thursday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-11 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-11 3:00pm")))),
          OpenStruct.new(attributes_for(:timesheet_with_activities, activities: friday,
                                        shift: OpenStruct.new(started_at: DateTime.parse("2019-04-12 7:00am"),
                                                              ended_at: DateTime.parse("2019-04-12 3:00pm")))),
        ]
      }

      it "should calculate correct regular and overtime hours" do
        result = TimesheetRulesEngine.new(timesheets).process_timesheets

        expect(result.regular).to eq(35.0)
        expect(result.overtime).to eq(0.0)
      end
    end
  end
end