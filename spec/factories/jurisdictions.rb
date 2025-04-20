# frozen_string_literal: true

FactoryBot.define do
  factory :jurisdiction do
    name { Faker::Name.unique.name }
    jurisdiction_type { 1 }
    parent_id { 1 }
    association :court, factory: :court
  end
end
