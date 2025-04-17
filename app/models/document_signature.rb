# frozen_string_literal: true

# Document Signature Model
class DocumentSignature < ApplicationRecord
  belongs_to :signable, polymorphic: true
  belongs_to :signer, class_name: 'CaseParticipant'

  validates :signature_data, presence: true
end
