# frozen_string_literal: true

FactoryBot.define do
  factory :hearing_note do
    content { Faker::Lorem.sentence }
    association :hearing, factory: :hearing
    association :author, factory: :user
  end
end
