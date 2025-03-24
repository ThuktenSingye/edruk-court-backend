# frozen_string_literal: true

FactoryBot.define do
  factory :case_type do
    title { Faker::Lorem.unique.word }
  end
end
