# frozen_string_literal: true

FactoryBot.define do
  factory :hearing do
    scheduled_date { Faker::Date.forward(days: 1) }
    hearing_status { :pending }
    description { Faker::Lorem.sentence }
    association :case, factory: :case
    association :hearing_type, factory: :hearing_type
    association :court, factory: :court
  end
end
