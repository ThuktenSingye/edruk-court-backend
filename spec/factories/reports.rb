# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    court { nil }
    generated_by { nil }
    report_status { 1 }
    generated_at { '2025-05-09 19:12:30' }
    metadata { '' }
  end
end
