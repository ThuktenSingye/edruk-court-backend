# frozen_string_literal: true

# Document Signature Model
class DocumentSignature < ApplicationRecord
  belongs_to :signable, polymorphic: true
  belongs_to :signer, class_name: 'User'

  validates :signature_data, presence: true

  encrypts :signature_data
end
