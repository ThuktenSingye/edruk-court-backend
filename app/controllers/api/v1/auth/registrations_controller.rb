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
            assign_default_role(resource) if resource.persisted?
          end
        end

        private

        def assign_default_role(user)
          default_role = Role.find_or_create_by!(name: 'User')
          user.add_role(default_role.name)
        end

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              status: 201, message: 'Signed up successfully.',
              data: UserSessionSerializer.new(resource).serializable_hash[:data][:attributes]
            }, status: :created
          else
            render json: {
              status: 422, message: resource.errors.full_messages.to_sentence.to_s
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
