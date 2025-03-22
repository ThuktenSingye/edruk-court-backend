# frozen_string_literal: true

# Clerk Model
class Clerk < ApplicationRecord
  acts_as_tenant :court
  belongs_to :user
end
