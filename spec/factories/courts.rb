# frozen_string_literal: true

FactoryBot.define do
  factory :court do
    name { Faker::Name.unique.name }
    court_type { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    contact_no { Faker::Number.number(digits: 8) }
    subdomain { Faker::Internet.domain_name }
    parent_court_id { 1 }
  end
end
