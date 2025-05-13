# frozen_string_literal: true

module Api
  module V1
    module Case
      # Case Types Controller
      class CaseTypesController < ApplicationController
        before_action :authenticate_user!

        def index
          @case_types = CaseType.all
          authorize @case_types
          render_json :ok, nil, serialized_case_types(@case_types)
        end

        private

        def serialized_case_types(case_types)
          case_types.map do |case_type|
            CaseTypeSerializer.new(case_type).serializable_hash[:data][:attributes]
          end
        end
      end
    end
  end
end
