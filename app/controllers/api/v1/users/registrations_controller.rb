module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
      end
    end
  end
end
