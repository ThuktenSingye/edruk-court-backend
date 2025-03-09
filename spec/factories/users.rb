# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
  end

  trait :password_confirmation do
    password_confirmation { 'password' }
  end

  trait :invalid_user do
    email { nil }
    password { nil }
    password_confirmation { nil }
  end
end
