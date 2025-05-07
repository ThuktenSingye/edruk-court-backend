# frozen_string_literal: true

FactoryBot.define do
  factory :court_order do
    order_type { 'Summon' }
    message { Faker::Lorem.sentence }
    issuance_court_id { 1 }
    issuing_user_id { 1 }
    association :case, factory: :case
  end
end
