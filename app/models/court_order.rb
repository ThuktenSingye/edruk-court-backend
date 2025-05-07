# frozen_string_literal: true

# Model Class for Court Order
class CourtOrder < ApplicationRecord
  belongs_to :case, optional: true
  belongs_to :issuance_court, class_name: 'Court', optional: true
  belongs_to :issuing_user, class_name: 'User', optional: true

  has_many_attached :documents
  has_many :order_recipient_courts, dependent: :nullify, inverse_of: :court_order
  has_many :order_recipient_users, dependent: :nullify, inverse_of: :court_order

  has_many :recipient_courts, through: :order_recipient_courts, source: :court
  has_many :recipient_users, through: :order_recipient_users, source: :user

  validates :message, presence: true
end
