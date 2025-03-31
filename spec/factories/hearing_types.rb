# frozen_string_literal: true

FactoryBot.define do
  factory :hearing_type do
    name { Faker::Internet.name }
  end

  trait :miscellaneous do
    name { 'miscellaneous' }
  end

  trait :preliminary do
    name { 'preliminary' }
  end

  trait :opening_statement do
    name { 'opening_statement' }
  end

  trait :rebuttal do
    name { 'rebuttal' }
  end

  trait :closing do
    name { 'closing' }
  end

  trait :investigation do
    name { 'investigation' }
  end

  trait :judgement do
    name { 'judgement' }
  end
end
