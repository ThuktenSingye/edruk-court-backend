# frozen_string_literal: true

# User Role
class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
end
