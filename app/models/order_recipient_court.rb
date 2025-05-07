# frozen_string_literal: true

# Model for Recipient Court
class OrderRecipientCourt < ApplicationRecord
  belongs_to :court_order
  belongs_to :court
end
