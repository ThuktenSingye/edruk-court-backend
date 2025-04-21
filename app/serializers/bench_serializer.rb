# frozen_string_literal: true

# Bench Serializer Class
class BenchSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :court_type, :parent_court, :judges, :clerks

  attribute :parent_court do |object|
    {
      id: object&.parent_court&.id,
      name: object&.parent_court&.name,
      court_type: object&.parent_court&.court_type
    }
  end

  attribute :judges do |object|
    object.users.with_role(:Judge, object).map do |judge|
      {
        id: judge.id,
        email: judge.email,
        first_name: judge.profile&.first_name,
        last_name: judge.profile&.last_name,
        cid_no: judge.profile&.cid_no,
        phone_number: judge.profile&.phone_number
      }
    end
  end

  attribute :clerks do |object|
    object.users.with_role(:Clerk, object).map do |clerk|
      {
        id: clerk.id,
        email: clerk.email,
        first_name: clerk.profile&.first_name,
        last_name: clerk.profile&.last_name,
        cid_no: clerk.profile&.cid_no,
        phone_number: clerk.profile&.phone_number
      }
    end
  end
end
