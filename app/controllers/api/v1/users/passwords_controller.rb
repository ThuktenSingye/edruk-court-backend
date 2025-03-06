module Api
  module V1
    module Users
      class PasswordsController < Devise::PasswordsController
        respond_to :json
      end
    end
  end
end
