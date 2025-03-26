# frozen_string_literal: true

FactoryBot.define do
  factory :case do
    case_number { Faker::Number.number(digits: 2).to_s }
    registration_number { Faker::Number.number(digits: 2).to_s }
    judgement_number { Faker::Number.number(digits: 2).to_s }
    title { Faker::Lorem.word }
    summary { Faker::Lorem.sentence }
    case_priority { :low }
    is_appeal { false }
    is_enforced { false }
    is_remanded { false }
    is_reopened { false }
    case_status { :filed }
    association :case_subtype, factory: :case_subtype
    association :court, factory: :court
  end
end
