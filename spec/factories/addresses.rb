# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    dzongkhag { 'MyString' }
    gewog { 'MyString' }
    street_address { 'MyString' }
    address_type { 1 }
    user { nil }
  end
end
