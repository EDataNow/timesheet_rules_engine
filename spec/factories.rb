require 'factory_bot'

FactoryBot.define do
  factory :timesheet, class: Hash do
    id { 1 }
    activities { [] }
  end
end