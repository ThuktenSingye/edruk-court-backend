# frozen_string_literal: true

# Common Case File Module
module CaseFile
  extend ActiveSupport::Concern

  included do
    belongs_to :hearing, optional: true
    has_many :document_signatures, as: :signable, dependent: :destroy

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
