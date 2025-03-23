# frozen_string_literal: true

module Api
  module V1
    # Address Controller
    class AddressesController < ApplicationController
      include JsonResponse
      before_action :authenticate_user!
      before_action :profile

      def create
        @address = @profile.addresses.build(address_params)

        if @address.save
          render_json :created, 'Address added successfully.',
                      AddressSerializer.new(@address).serializable_hash[:data][:attributes]
        else
          render_json :unprocessable_entity, 'Failed to add address.', errors: @address.errors
        end
      end

      private

      def profile
        @profile ||= current_user.profile
      end

      def address_params
        params.expect(address: %i[dzongkhag gewog street_address address_type])
      end
    end
  end
end
