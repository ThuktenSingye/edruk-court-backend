# frozen_string_literal: true

FactoryBot.define do
  factory :document_signature do
    signature_data { 'MyText' }
    sign_at { '2025-04-17 20:39:44' }
    signer_id { '' }
    signable { nil }
  end
end
