# frozen_string_literal: true

# Jurisdiction Model
class Jurisdiction < ApplicationRecord
  belongs_to :court
  belongs_to :parent, class_name: 'Jurisdiction', optional: true
  has_many :child_jurisdictions, class_name: 'Jurisdiction', foreign_key: 'parent_id', dependent: :destroy,
                                 inverse_of: :parent

  enum :jurisdiction_type, { dzongkhag: 0, gewog: 1 }

  validates :name, :jurisdiction_type, presence: true
end
