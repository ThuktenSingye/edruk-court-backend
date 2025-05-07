# frozen_string_literal: true

FactoryBot.define do
  factory :order_recipient_court do
    court_order { nil }
    court { nil }
    read_at { '2025-05-08 02:21:16' }
    read_status { 1 }
  end
end
