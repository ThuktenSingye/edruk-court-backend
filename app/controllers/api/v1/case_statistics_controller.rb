# frozen_string_literal: true

module Api
  module V1
    # Case Statistics Controller
    class CaseStatisticsController < ApplicationController
      before_action :authenticate_user!

      def index
        year = params[:year].presence || Date.current.year
        case_statistics_service = CaseStatisticService.new(year: year, court: current_tenant)
        case_stats_data = case_statistics_service.case_statictic
        authorize case_stats_data, policy_class: CaseStatisticPolicy
        render_json :ok, 'Case Statistics', case_stats_data
      end
    end
  end
end
