# frozen_string_literal: true

# Role Model
class Role < ApplicationRecord
  has_many :user_roles, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
