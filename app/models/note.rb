# frozen_string_literal: true

# Note Model
class Note < ApplicationRecord
  belongs_to :user
  belongs_to :hearing

  validates :content, presence: true
end
