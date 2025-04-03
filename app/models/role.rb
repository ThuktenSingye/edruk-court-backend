# frozen_string_literal: true

# Role Model
class Role < ApplicationRecord
  rolify

  belongs_to :resource, polymorphic: true, optional: true

  validates :name, presence: true, uniqueness: true
end
