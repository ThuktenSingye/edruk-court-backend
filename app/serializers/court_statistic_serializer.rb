# frozen_string_literal: true

# Court Statistic Serializer
class CourtStatisticSerializer
  include JSONAPI::Serializer
  set_id { nil }

  attributes :supreme_court, :high_court, :dzongkhag_court, :dungkhag_court, :bench

  attribute :supreme_court do |object|
    object[:supreme_court]
  end

  attribute :high_court do |object|
    object[:high_court]
  end

  attribute :dzongkhag_court do |object|
    object[:dzongkhag_court]
  end

  attribute :dungkhag_court do |object|
    object[:dungkhag_court]
  end

  attribute :bench do |object|
    object[:bench]
  end
end
