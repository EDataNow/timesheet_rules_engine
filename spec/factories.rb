require 'factory_bot'
require 'date'

FactoryBot.define do
  factory :timesheet_no_activities, class: Hash do
    id { 1 }
    activities { [] }
    scheduled_shift { OpenStruct.new(started_at: DateTime.parse("2018-01-01 6:00am"), ended_at: DateTime.parse("2018-01-01 4:30pm")) }
  end

  factory :timesheet_with_activities, class: Hash do
    id { 1 }
    activities { [] }
  end

  factory :activity, class: Hash do
    id { 1 }
    type { nil }
    total_hours { 1.0 }
    paid { true }
    paid_overtime { true }
    billed { true }
    from { DateTime.parse("2018-01-01 9:00AM") }
    to { DateTime.parse("2018-01-01 1:00PM") }
  end
end