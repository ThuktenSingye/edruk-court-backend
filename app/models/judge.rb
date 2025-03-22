# frozen_string_literal: true

# Judge Model
class Judge < ApplicationRecord
  acts_as_tenant :court
  belongs_to :user
end
