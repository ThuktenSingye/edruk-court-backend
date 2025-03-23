# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    cid_no { Faker::Number.number(digits: 11).to_s }
    phone_number { Faker::PhoneNumber.phone_number }
    house_no { Faker::Number.number(digits: 5).to_s }
    thram_no { Faker::Number.number(digits: 5).to_s }
    age { 10 }
    gender { 1 }
    association :user, factory: :user
  end
end
