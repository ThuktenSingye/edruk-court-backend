# frozen_string_literal: true

# Case Json Serializer
class CaseSerializer
  include JSONAPI::Serializer

  attributes :id, :case_number, :registration_number, :judgement_number, :title, :summary, :judge, :clerk,
             :court, :original_case_id

  attribute :case_status do |object|
    object.case_status&.humanize
  end

  attribute :case_priority do |object|
    object.case_priority&.humanize
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

  attribute :hearings do |object|
    object.hearings.map do |hearing|
      {
        id: hearing.id,
        hearing_type: hearing.hearing_type.name,
        hearing_status: hearing.hearing_status
      }
    end
  end

  attribute :judge do |object|
    judge = object.case_participants
                  .find_by(role_id: Role.find_by(name: 'Judge').id)&.user
    judge&.profile&.then { |p| "#{p.first_name} #{p.last_name}" }
  end

  attribute :clerk do |object|
    clerk = object.case_participants
                  .find_by(role_id: Role.find_by(name: 'Clerk').id)&.user
    clerk&.profile&.then { |p| "#{p.first_name} #{p.last_name}" }
  end


  attribute :court do |object|
    object.court.name
  end
end
