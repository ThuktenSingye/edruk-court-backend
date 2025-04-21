# frozen_string_literal: true

# Case Json Serializer
class CaseSerializer
  include JSONAPI::Serializer

  attributes :case_number, :registration_number, :judgement_number, :title, :summary

  attribute :case_status do |object|
    object.case_status.humanize
  end

  attribute :case_priority do |object|
    object.case_priority.humanize
  end

  attribute :documents do |object|
    object.case_documents.map do |document|
      {
        id: document.id,
        verified_at: document.verified_at,
        verified_by_judge: document.verified_by_judge,
        document_status: document.document_status,
        file: if document.document.attached?
                {
                  url: Rails.application.routes.url_helpers.url_for(document.document),
                  filename: document.document.filename.to_s,
                  content_type: document.document.content_type,
                  byte_size: document.document.byte_size
                }
              end
      }
    end
  end
end
