# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Registration Controller
      class RegistrationsController < Devise::RegistrationsController
        include RackSessionsFix

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              status: 201, message: 'Signed up successfully.'
            }, status: :created
          else
            render json: {
              status: 422, message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
            }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.expect(user: %i[email password password_confirmation])
        end
      end
    end
  end
end
