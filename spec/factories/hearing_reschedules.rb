FactoryBot.define do
  factory :hearing_reschedule do
    original_date { Faker::Date.backward(days: 1) }
    new_date { Faker::Date.forward(days: 5) }
    reason { Faker::Lorem.sentence }
    association :hearing, factory: :hearing
    association :rescheduled_by, factory: :user
  end
end
