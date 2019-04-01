require 'factory_bot'

FactoryBot.define do
  factory :timesheet_no_activities, class: Hash do
    id { 1 }
    activities { [] }
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
  end
end