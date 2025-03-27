# frozen_string_literal: true

FactoryBot.define do
  factory :hearing_schedule do
    scheduled_date { Faker::Date.forward(days: 1) }
    schedule_status { 1 }
    reschedule_reason { Faker::Lorem.sentence }
    association :hearing, factory: :hearing
    association :author, factory: :user
  end
end
