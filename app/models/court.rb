# frozen_string_literal: true

# Court Model
class Court < ApplicationRecord
  has_many :jurisdictions, dependent: :nullify
  belongs_to :parent_court, class_name: 'Court', optional: true
  has_many :child_courts, class_name: 'Court', foreign_key: :parent_court_id, dependent: :destroy,
                          inverse_of: :parent_court
  has_many :users, dependent: :nullify
  has_many :cases, dependent: :nullify
  has_many :hearings, through: :cases
  has_many :hearing_schedules, through: :hearings

  enum :court_type, { supreme: 0, high: 1, dzongkhag: 2, dungkhag: 3, bench: 4 }

  validates :name, :court_type, :email, :contact_no, presence: true
  validates :domain, :subdomain, :name, :email, uniqueness: { case_sensitive: false }

  delegate :today_approved,
           :pending,
           :overdue,
           :reminder,
           to: :hearing_schedules, prefix: true
end
