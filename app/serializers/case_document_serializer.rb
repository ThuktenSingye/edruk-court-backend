# frozen_string_literal: true

# Case Document Serializer
class CaseDocumentSerializer
  include JSONAPI::Serializer

  attributes :id, :verified_at, :verified_by_judge, :document_status

  attribute :document_status do |object|
    object.document_status.humanize
  end

  attribute :document do |object|
    if object.document.attached?
      {
        url: Rails.application.routes.url_helpers.rails_blob_url(object.document, only_path: true),
        filename: object.document.filename.to_s,
        content_type: object.document.content_type,
        byte_size: object.document.byte_size
      }
    end
  end

  belongs_to :hearing
end
