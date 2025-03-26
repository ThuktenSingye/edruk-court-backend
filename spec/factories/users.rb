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
      role = Role.find_or_create_by(name: 'Admin')
      user.roles << role
    end
  end

  trait :clerk do
    after(:create) do |user|
      role = Role.find_or_create_by(name: 'Clerk')
      user.roles << role
    end
  end

  # Associate user with roles
  trait :registrar do
    after(:create) do |user|
      role = Role.find_or_create_by(name: 'Registrar')
      user.roles << role
    end
  end

  trait :judge do
    after(:create) do |user|
      role = Role.find_or_create_by(name: 'Judge')
      user.roles << role
    end
  end

  trait :court_user do
    association :court, factory: :court
  end
end
