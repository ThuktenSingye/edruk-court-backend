# frozen_string_literal: true

FactoryBot.define do
  factory :court do
    name { Faker::Name.unique.name }
    court_type { 1 }
    email { Faker::Internet.unique.email }
    contact_no { Faker::Number.number(digits: 8) }
    subdomain { Faker::Internet.unique.domain_name }
    domain { Faker::Internet.unique.domain_name }
    parent_court_id { nil }
    association :location, factory: :location
  end
end
