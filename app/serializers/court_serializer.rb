# frozen_string_literal: true

# Court Serializer
class CourtSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :email, :contact_no, :subdomain, :domain, :court_type

  attribute :court_type do |object|
    object.court_type.humanize
  end

  attribute :parent_court do |object|
    {
      id: object.parent_court&.id,
      name: object.parent_court&.name,
      type: object.parent_court&.court_type&.humanize
    }
  end
end
