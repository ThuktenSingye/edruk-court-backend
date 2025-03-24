# frozen_string_literal: true

# CaseType Model
class CaseType < ApplicationRecord
  has_many :case_subtypes, dependent: :destroy

  validates :title, presence: true, uniqueness: { case_sensitive: false }
end
