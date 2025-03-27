# frozen_string_literal: true

# Hearing Note Model
class HearingNote < ApplicationRecord
  belongs_to :hearing
  belongs_to :author, class_name: 'User'

  validates :content, presence: true
end
