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

  # Associate user with roles
  trait :admin do
    after(:create) do |user|
      user.add_role('Admin')
    end
  end

  trait :clerk do
    after(:create) do |user|
      user.add_role('Clerk')
    end
  end

  # Associate user with roles
  trait :registrar do
    after(:create) do |user|
      user.add_role('Registrar')
    end
  end

  trait :judge do
    after(:create) do |user|
      user.add_role('Judge')
    end
  end

  trait :court_user do
    association :court, factory: :court
  end
end
