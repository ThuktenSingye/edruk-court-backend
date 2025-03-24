# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { 'User' }
  end

  trait :admin do
    name { 'Admin' }
  end

  trait :judge do
    name { 'Judge' }
  end

  trait :clerk do
    name { 'Clerk' }
  end

  trait :registrar do
    name { 'Registrar' }
  end

  trait :plaintiff do
    name { 'Plaintiff' }
  end

  trait :defendent do
    name { 'Defendent' }
  end

  trait :lawyer do
    name { 'Lawyer' }
  end

  trait :prosecutor do
    name { 'Prosecutor' }
  end
end
