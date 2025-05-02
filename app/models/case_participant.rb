# frozen_string_literal: true

# Case Participant Table
class CaseParticipant < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :case
  belongs_to :role, optional: true
end
