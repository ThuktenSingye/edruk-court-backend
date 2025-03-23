# frozen_string_literal: true

module Api
  module V1
    module Auth
      # Login/Sign out Controller
      class SessionsController < Devise::SessionsController
        include RackSessionsFix

        respond_to :json

        def create
          if current_tenant
            authenticate_user
          else
            handle_court_not_found
          end
        end

        private

        def authenticate_user
          @user = current_tenant.users.find_by(email: params[:user][:email])
          if @user
            sign_in(@user)
            respond_with(@user, success: true)
          else
            handle_invalid_credentials
          end
        end

        def handle_invalid_credentials
          respond_with(nil, success: false, message: I18n.t('login.error.credentials'), status: :unauthorized)
        end

        def handle_court_not_found
          respond_with(nil, success: false, message: I18n.t('login.error.court_not_found'), status: :unauthorized)
        end

        def respond_with(current_user, opts = {})
          status = opts[:status] || :ok
          message = opts[:message] || I18n.t('login.success')
          data = current_user ? UserSerializer.new(current_user).serializable_hash[:data][:attributes] : nil

          render json: { status: status == :ok ? 200 : status, message: message, data: data }, status: status
        end

        # rubocop:disable Metrics/AbcSize
        def respond_to_on_destroy
          if request.headers['Authorization'].present?
            jwt_payload = JWT.decode(request.headers['Authorization'].split.last,
                                     Rails.application.credentials.devise_jwt_secret_key!).first
            current_user = User.find(jwt_payload['sub'])
          end
          if current_user
            render json: { status: 200, message: I18n.t('logout.success') }, status: :ok
          else
            render json: { status: 401, message: I18n.t('logout.error.unauthorized') }, status: :unauthorized
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
