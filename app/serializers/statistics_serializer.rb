# frozen_string_literal: true

# Statistics Serializer
class StatisticsSerializer
  include JSONAPI::Serializer

  set_id { nil }

  attributes :total, :civil, :criminal, :others,
             :active, :decided, :appeal

  attribute :total do |object|
    object[:total]
  end

  attribute :civil do |object|
    object[:civil]
  end

  attribute :criminal do |object|
    object[:criminal]
  end

  attribute :others do |object|
    object[:others]
  end

  attribute :active do |object|
    object[:active]
  end

  attribute :decided do |object|
    object[:decided]
  end

  attribute :appeal do |object|
    object[:appeal]
  end
end
