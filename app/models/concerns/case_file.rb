# frozen_string_literal: true

# Common Case File Module
module CaseFile
  extend ActiveSupport::Concern

  included do
    belongs_to :hearing
    has_many :document_signatures, as: :signable, dependent: :destroy

    validates :hash_value, presence: true
    validates :hash_value, uniqueness: { case_sensitive: false }

    scope :pre_hearing, lambda {
      joins(hearing: :hearing_type)
        .where(hearing_types: { name: 'miscellaneous' })
    }

    scope :post_hearing, lambda {
      joins(hearing: :hearing_type)
        .where.not(hearing_types: { name: 'miscellaneous' })
    }
  end
end
