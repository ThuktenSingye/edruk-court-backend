# frozen_string_literal: true

module Api
  module V1
    class HearingTypesController < ApplicationController
      before_action :authenticate_user!

      def index; end
    end
  end
end
