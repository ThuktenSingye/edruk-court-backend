# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Confirmation Controller
      class ConfirmationsController < Devise::ConfirmationsController
        include RackSessionsFix

        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.errors.empty?
            render json: {
              status: 200, message: 'Confirmation Successful.'
            }, status: :ok
          else
            error_messages = resource.errors.map(&:message).to_sentence
            render json: { status: 422, message: error_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
