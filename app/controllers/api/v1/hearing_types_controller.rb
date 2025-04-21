# frozen_string_literal: true

module Api
  module V1
    # Hearing Types Controller
    class HearingTypesController < ApplicationController
      before_action :authenticate_user!

      def index
        @hearing_types = policy_scope(HearingType.all)
        authorize @hearing_types
        render_json :ok, nil, serialized_hearing_types(@hearing_types)
      end

      private

      def serialized_hearing_types(hearing_types)
        hearing_types.map do |hearing_type|
          HearingTypeSerializer.new(hearing_type).serializable_hash[:data][:attributes]
        end
      end
    end
  end
end
