# frozen_string_literal: true

# Hearing Serializer
class HearingSerializer
  include JSONAPI::Serializer

  attributes :id, :hearing_status, :case_number, :summary

  attribute :hearing_type do |hearing|
    hearing.hearing_type.name
  end

  attribute :schedules do |hearing|
    hearing.hearing_schedules&.map do |schedule|
      {
        id: schedule.id,
        scheduled_date: schedule.scheduled_date.iso8601,
        schedule_status: schedule.schedule_status,
        scheduled_by: schedule.scheduled_by_id
      }
    end
  end

  attribute :case_number do |object|
    object.case.case_number
  end

  attribute :summary do |object|
    object.case.summary
  end

  attribute :documents do |object, params|
    current_user = params[:current_user]
    # documents = if object.hearing_type.name.downcase == 'miscellaneous'
    #               if current_user&.judge?
    #                 object.case.case_documents.where(document_status: 'verified')
    #               else
    #                 object.case.case_documents
    #               end
    #             elsif current_user&.judge?
    #               object.case_documents.where(document_status: 'verified')
    #             else
    #               object.case_documents
    #             end
    documents =
      if object.hearing_type.name.downcase == 'miscellaneous'
        # rubocop:disable Layout/LineLength
        current_user&.judge? ? object.case.case_documents.where(document_status: 'verified') : object.case.case_documents
        # rubocop:enable Layout/LineLength
      else
        current_user&.judge? ? object.case_documents.where(document_status: 'verified') : object.case_documents
      end
    documents.map do |document|
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

  attribute :evidences do |object|
    object.case_evidences.map do |evidence|
      {
        id: evidence.id,
        verified_at: evidence.verified_at,
        verified_by_judge: evidence.verified_by_judge,
        evidence_status: evidence.evidence_status,
        file: if evidence.evidence.attached?
                {
                  url: Rails.application.routes.url_helpers.url_for(evidence.evidence),
                  filename: evidence.evidence.filename.to_s,
                  content_type: evidence.evidence.content_type,
                  byte_size: evidence.evidence.byte_size
                }
              end
      }
    end
  end
end
