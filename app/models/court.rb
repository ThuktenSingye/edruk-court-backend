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

  # Court orders issued by this court
  # rubocop:disable Rails/InverseOf
  has_many :issued_court_orders, class_name: 'CourtOrder', foreign_key: 'issuance_court_id', dependent: :destroy
  # rubocop:enable Rails/InverseOf

  # Court orders received by this court
  has_many :order_recipient_courts, dependent: :destroy
  has_many :received_court_orders, through: :order_recipient_courts, source: :court_order

  has_many :primary_cases, class_name: 'Case', dependent: :nullify
  has_many :bench_cases, class_name: 'Case', foreign_key: 'bench_id', dependent: :nullify, inverse_of: :bench
  has_many :reports, dependent: :nullify

  enum :court_type, { supreme: 0, high: 1, dzongkhag: 2, dungkhag: 3, bench: 4 }

  validates :name, :court_type, :email, :contact_no, presence: true
  validates :domain, :subdomain, :name, :email, uniqueness: { case_sensitive: false }

  delegate :today_approved,
           :pending,
           :overdue,
           :reminder,
           to: :hearing_schedules, prefix: true

  scope :supreme_courts, -> { where(court_type: :supreme) }
  scope :high_courts, -> { where(court_type: :high) }
  scope :dzongkhag_courts, -> { where(court_type: :dzongkhag) }
  scope :dungkhag_courts, -> { where(court_type: :dungkhag) }
  scope :benches, -> { where(court_type: :bench) }

  def bench?
    court_type == 'bench'
  end

  def bench_exist?
    child_courts.exists?(court_type: :bench)
  end

  def cases
    Case.where('court_id = ? OR bench_id = ?', id, id)
  end
end
