# frozen_string_literal: true

# Address Json Serializer
class AddressSerializer
  include JSONAPI::Serializer
  attributes :dzongkhag, :gewog, :street_address, :address_type
end
