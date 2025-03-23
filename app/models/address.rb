# frozen_string_literal: true

# Address Model
class Address < ApplicationRecord
  belongs_to :profile

  enum :address_type, { present: 0, permanent: 1 }

  validates :dzongkhag, :gewog, :street_address, :address_type, presence: true
end
