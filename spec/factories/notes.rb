# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    content { Faker::Lorem.sentence }
    association :user, factory: :user
    association :hearing, factory: :hearing
  end
end
