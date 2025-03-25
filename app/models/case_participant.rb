# frozen_string_literal: true

# Case Participant Table
class CaseParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :case
  belongs_to :role
end
