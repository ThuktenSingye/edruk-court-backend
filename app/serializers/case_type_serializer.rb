# frozen_string_literal: true

# Case Type Serializer
class CaseTypeSerializer
  include JSONAPI::Serializer
  attributes :id, :title

  attribute :subtype do |object|
    object.case_subtypes.map do |subtype|
      {
        id: subtype.id,
        title: subtype.title
      }
    end
  end
end
