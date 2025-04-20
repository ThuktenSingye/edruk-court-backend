# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Admin Base Controller
      class BaseController < ApplicationController
        before_action :authenticate_user!
        before_action :authorize_admin!

        private

        def authorize_admin!
          return if current_user.admin?

          render_json :unauthorized, 'You are not authorized to perform this action', nil
        end
      end
    end
  end
end
