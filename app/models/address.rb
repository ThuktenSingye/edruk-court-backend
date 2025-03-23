# frozen_string_literal: true

# User Address Model
class Address < ApplicationRecord
  belongs_to :user

  enum :address_type, { present: 0, permanent: 1 }

  validates :dzongkhag, :gewog, :street_address, :address_type, presence: true
end
