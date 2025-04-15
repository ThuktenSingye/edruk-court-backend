# frozen_string_literal: true

# Hearing Model
class Hearing < ApplicationRecord
  belongs_to :case
  belongs_to :hearing_type
  has_many :hearing_schedules, dependent: :destroy
  has_many :notes, dependent: :destroy
  accepts_nested_attributes_for :hearing_schedules, allow_destroy: true

  enum :hearing_status, { ongoing: 0, completed: 1, pending: 2, dismissed: 3 }

  validates :hearing_status, presence: true
end
