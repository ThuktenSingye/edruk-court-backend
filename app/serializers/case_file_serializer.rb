# frozen_string_literal: true

# app/serializers/case_file_serializer.rb
class CaseFileSerializer
  include JSONAPI::Serializer

  attributes :id, :hearing_status, :case_id

  attribute :hearing_type do |object|
    { name: object.hearing_type&.name }
  end

  attribute :case_documents do |object, params|
    current_user = params[:current_user]
    documents = if current_user&.judge?
                  object.case_documents.where(document_status: 'verified')
                else
                  object.case_documents
                end
    documents.map do |doc|
      {
        id: doc.id,
        verified_by_judge: doc.verified_by_judge,
        document_status: doc.document_status,
        created_at: doc.created_at,
        document_url: doc.document_url
      }
    end
  end

  attribute :case_evidences do |object|
    object.case_evidences.map do |evidence|
      {
        id: evidence.id,
        verified_by_judge: evidence.verified_by_judge,
        evidence_status: evidence.evidence_status,
        created_at: evidence.created_at,
        evidence_url: evidence.evidence_url
      }
    end
  end
end
