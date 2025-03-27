module Api
  module V1
    module Case
      class HearingsController < ApplicationController
        before_action :authenticate_user!

        def index; end
        def show;end
        def create; end
        def update; end
        def destroy; end

        private

        def hearing_params
          # params.expect(hearing: )
        end

      end
    end
  end
end

