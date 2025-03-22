# frozen_string_literal: true

# Registrar Model
class Registrar < ApplicationRecord
  acts_as_tenant :court
  belongs_to :user
end
