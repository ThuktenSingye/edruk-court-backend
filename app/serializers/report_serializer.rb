# frozen_string_literal: true

# Report Serializer
class ReportSerializer
  include JSONAPI::Serializer
  attributes :id, :report_status, :generated_at, :year

  attribute :report_status do |object|
    object.report_status.humanize
  end

  attribute :file do |object|
    if object.file.attached?
      {
        url: Rails.application.routes.url_helpers.url_for(object.file),
        filename: object.file.filename.to_s,
        content_type: object.file.content_type,
        byte_size: object.file.byte_size
      }
    end
  end
end
