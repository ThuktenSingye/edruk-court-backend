module Api
  module V1
    module Auth
      class PasswordsController < Devise::PasswordsController
        include RackSessionsFix

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.errors.empty?
            render json: {
              status: { code: 200, message: "Password reset instructions sent successfully." }
            }, status: :ok
          else
            render json: {
              status: { message: "#{resource.errors.full_messages.to_sentence}" }
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
