# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Registration Controller
      class RegistrationsController < Devise::RegistrationsController
        include RackSessionsFix

        respond_to :json

        def create
          super do |resource|
            if resource.persisted?
              default_role = Role.find_or_create_by!(name: 'User')
              UserRole.find_or_create_by!(user: resource, role: default_role)
              # Generate Private and Public key Pair
            end
          end
        end

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              status: 201, message: 'Signed up successfully.'
            }, status: :created
          else
            render json: {
              status: 422, message: resource.errors.full_messages.to_sentence.to_s
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
