# frozen_string_literal: true

module Api
  module V1
    module Case
      # Controller for report generation
      class ReportsController < ApplicationController
        before_action :authenticate_user!

        def generate
          year = params[:year].presence || Date.current.year
          report_service = Reports::AnnualCourtReportService.new(year: year.to_i, court: current_tenant)
          report_data = report_service.generate
          authorize report_data, policy_class: ReportPolicy
          render_json :ok, 'Report Generated', report_data
        end
      end
    end
  end
end
