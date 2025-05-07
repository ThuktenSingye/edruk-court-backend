# frozen_string_literal: true

FactoryBot.define do
  factory :order_recipient_user do
    court_order { nil }
    user { nil }
    read_at { '2025-05-08 02:21:30' }
    read_status { 1 }
  end
end
