# frozen_string_literal: true

# Court Order Serializer
class CourtOrderSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :message, :case_id, :order_type, :issuance_court_id, :issuing_user_id, :created_at, :updated_at

  attribute :court_sender do |object|
    if object.issuance_court
      {
        id: object.issuance_court.id,
        name: object.issuance_court.name,
        court_type: object.issuance_court.court_type.humanize
      }
    end
  end

  attribute :user_sender do |object|
    if object.issuing_user
      {
        id: object.issuing_user.id,
        first_name: object.issuing_user&.profile&.first_name,
        last_name: object.issuing_user&.profile&.last_name
      }
    end
  end

  attribute :documents do |court_order|
    court_order.documents.filter_map do |document|
      {
        id: document.id,
        url: Rails.application.routes.url_helpers.url_for(document),
        filename: document.filename.to_s,
        content_type: document.content_type,
        byte_size: document.byte_size
      }
    end
  end
end
