# frozen_string_literal: true

FactoryBot.define do
  factory :case_type do
    title { Faker::Lorem.word }
  end

  trait :civil do
    title { 'Civil' }
  end

  trait :criminal do
    title { 'Criminal' }
  end

  trait :other do
    title { 'Other' }
  end
end
