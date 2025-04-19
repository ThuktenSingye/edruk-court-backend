# frozen_string_literal: true

FactoryBot.define do
  factory :case_evidence do
    hash_value { Faker::Lorem.sentence }
    verified_by_judge { false }
    verified_at { '2025-04-17 21:30:04' }
    evidence_status { 1 }
    file_type { 'MyString' }
    is_encrypted { false }
    iv { Faker::Lorem.paragraph }
    auth_tag { Faker::Lorem.characters(number: 5) }
    encrypted_key { Faker::Lorem.characters(number: 10) }
    association :hearing, factory: :hearing
  end

  trait :with_image do
    after(:build) do |case_evidence|
      case_evidence.evidence.attach(
        io: Rails.root.join('spec/support/images/banner.jpg').open,
        filename: 'image/jpg'
      )
    end
  end
end
