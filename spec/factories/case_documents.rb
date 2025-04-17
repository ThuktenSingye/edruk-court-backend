# frozen_string_literal: true

FactoryBot.define do
  factory :case_document do
    hash_value { Faker::Lorem.paragraph }
    verified_by_judge { false }
    verified_at { '2025-04-17 21:23:01' }
    document_status { 1 }
    association :hearing, factory: :hearing
  end
end
