module Api
  module V1
    module Auth
      class RegistrationsController < Devise::RegistrationsController
        include RackSessionsFix

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: {
              status: { code: 201, message: "Signed up successfully." }
            }, status: :created
          else
            render json: {
              status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
            }, status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
