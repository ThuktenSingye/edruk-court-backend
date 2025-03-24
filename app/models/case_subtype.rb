# frozen_string_literal: true

# Case Subtype Model
class CaseSubtype < ApplicationRecord
  belongs_to :case_type

  validates :title, presence: true, uniqueness: { case_sensitive: false }
end
