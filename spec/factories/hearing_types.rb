# frozen_string_literal: true

FactoryBot.define do
  factory :hearing_type do
    name { Faker::Internet.unique.name }
  end
end
