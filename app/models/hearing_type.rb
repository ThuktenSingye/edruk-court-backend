# frozen_string_literal: true

# Hearing Type Model
class HearingType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
