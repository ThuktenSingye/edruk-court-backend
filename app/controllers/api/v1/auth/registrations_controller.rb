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
          role_param = params[:user][:role].to_s.downcase

          valid_roles = %w[organization user]
          role_name = valid_roles.include?(role_param) ? role_param.capitalize : 'User'

          role_record = Role.find_or_create_by!(name: role_name)
          user.add_role(role_record.name)
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
