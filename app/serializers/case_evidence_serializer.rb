# frozen_string_literal: true

# Case Evidence Serializer
class CaseEvidenceSerializer
  include JSONAPI::Serializer

  attributes :id, :verified_at, :verified_by_judge, :evidence_status

  attribute :evidence_status do |object|
    object.evidence_status.humanize
  end

  attribute :evidence do |object|
    if object.evidence.attached?
      {
        url: Rails.application.routes.url_helpers.url_for(object.evidence),
        filename: object.evidence.filename.to_s,
        content_type: object.evidence.content_type,
        byte_size: object.evidence.byte_size
      }
    end
  end

  belongs_to :hearing
end
