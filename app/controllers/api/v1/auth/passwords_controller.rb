# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Password Reset Controller
      class PasswordsController < Devise::PasswordsController
        include RackSessionsFix

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.errors.empty?
            render json: {
              status: { code: 200, message: 'Password reset instructions sent successfully.' }
            }, status: :ok
          else
            render json: {
              status: { message: resource.errors.full_messages.to_sentence.to_s }
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
