# frozen_string_literal: true

module Api
  module V1
    # Court Controller for Court Official
    class CourtsController < ApplicationController
      before_action :authenticate_user!

      def index
        @courts = Court.all
        authorize @courts, policy_class: CourtPolicy
        render_json :ok, nil, serialized_courts(@courts)
      end

      private

      def serialized_courts(courts)
        courts.map do |court|
          CourtSerializer.new(court).serializable_hash[:data][:attributes]
        end
      end
    end
  end
end
