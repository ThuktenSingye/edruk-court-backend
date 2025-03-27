# frozen_string_literal: true

FactoryBot.define do
  factory :hearing do
    hearing_status { :ongoing }
    association :case, factory: :case
    association :hearing_type, factory: :hearing_type
  end
end
