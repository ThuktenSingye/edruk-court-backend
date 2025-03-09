# frozen_string_literal: true

FactoryBot.define do
  factory :user_role do
    user { 1 }
    role { 1 }
  end
end
