# frozen_string_literal: true

FactoryBot.define do
  factory :hearing_type do
    name { Faker::Internet.name }
  end
end
