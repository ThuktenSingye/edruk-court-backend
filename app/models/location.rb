# frozen_string_literal: true

# Location Model Definition
class Location < ApplicationRecord
  belongs_to :parent, class_name: 'Location', optional: true
  has_many :child_locations, class_name: 'Location', foreign_key: 'parent_id', dependent: :destroy,
                             inverse_of: :parent

  enum :location_type, { dzongkhag: 0, gewog: 1 }

  validates :name, :location_type, presence: true
end
