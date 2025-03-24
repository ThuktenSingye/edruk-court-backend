# frozen_string_literal: true

FactoryBot.define do
  factory :case_subtype do
    title { Faker::Lorem.unique.word }
    association :case_type, factory: :case_type
  end
end
