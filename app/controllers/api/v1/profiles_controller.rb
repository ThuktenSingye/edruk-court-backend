# frozen_string_literal: true

module Api
  module V1
    # Profile Controller
    class ProfilesController < ApplicationController
      include JsonResponse
      before_action :authenticate_user!
      before_action :profile, only: %i[update]

      def show
        profile = current_user.profile
        data = ProfileSerializer.new(profile).serializable_hash[:data][:attributes] if profile
        render_json :ok, 'Profile Data', data
      end

      def update
        if @profile.update(profile_params)
          render_json :ok, 'Profile Updated Successfully',
                      ProfileSerializer.new(@profile).serializable_hash[:data][:attributes]
        else
          render_json :unprocessable_entity, 'Failed to update profile', errors: @profile.errors
        end
      end

      private

      def profile
        @profile ||= current_user.profile
      end

      def profile_params
        params.expect(profile: [:first_name, :last_name, :cid_no, :phone_number, :house_no, :thram_no, :age, :gender,
                                { addresses_attributes: %i[id dzongkhag gewog street_address address_type] }])
      end
    end
  end
end
