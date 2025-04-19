# frozen_string_literal: true

FactoryBot.define do
  factory :case_document do
    hash_value { Faker::Lorem.paragraph }
    verified_by_judge { false }
    verified_at { '2025-04-17 21:23:01' }
    document_status { 1 }
    association :hearing, factory: :hearing
  end

  trait :with_document do
    after(:build) do |case_document|
      case_document.document.attach(
        io: Rails.root.join('spec/support/documents/dummy.pdf').open,
        filename: 'dummy.pdf'
      )
    end
  end
end
