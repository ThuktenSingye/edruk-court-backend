# frozen_string_literal: true

FactoryBot.define do
  factory :case_participant do
    association :user, factory: :user
    association :case, factory: :case
    association :role, factory: :role
  end
end
