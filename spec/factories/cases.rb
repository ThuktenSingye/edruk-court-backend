# frozen_string_literal: true

FactoryBot.define do
  factory :case do
    case_id { 'MyString' }
    title { 'MyString' }
    summary { 'MyText' }
    case_priority { 1 }
    is_appeal { false }
    is_enforced { false }
    is_remanded { false }
    is_reopened { false }
    case_status { 1 }
    court { nil }
    case_subtype { nil }
  end
end
