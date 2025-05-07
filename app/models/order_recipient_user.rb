# frozen_string_literal: true

# Model for recipient User
class OrderRecipientUser < ApplicationRecord
  belongs_to :court_order
  belongs_to :user
end
