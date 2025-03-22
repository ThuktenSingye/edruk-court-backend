# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    name { 'MyString' }
    location_type { 1 }
    parent_id { 1 }
  end
end
