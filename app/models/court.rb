# frozen_string_literal: true

# Court Model
class Court < ApplicationRecord
  belongs_to :location
  belongs_to :parent_court, class_name: 'Court', optional: true
  has_many :child_courts, class_name: 'Court', foreign_key: :parent_court_id, dependent: :destroy,
                          inverse_of: :parent_court
  has_many :users, dependent: :nullify

  enum :court_type, { supreme: 0, high: 1, dzongkhag: 2, dungkhag: 3, bench: 4 }

  validates :name, :court_type, :email, :contact_no, presence: true

  validates :domain, :subdomain, :name, :email, uniqueness: { case_sensitive: false }
end
