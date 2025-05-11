# frozen_string_literal: true

# Report model
class Report < ApplicationRecord
  belongs_to :court
  belongs_to :generated_by, class_name: 'User', optional: true

  has_one_attached :file

  enum :report_status, { processing: 0, completed: 1, failed: 2 }
end
