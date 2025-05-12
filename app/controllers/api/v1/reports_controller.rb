# frozen_string_literal: true

module Api
  module V1
    # Controller for report generation
    class ReportsController < ApplicationController
      before_action :authenticate_user!

      def index
        @reports = current_tenant.reports.order(created_at: :asc)
        authorize @reports, policy_class: ReportPolicy
        render_json :ok, nil, serialized_reports(@reports)
      end

      def generate
        year = params[:year].presence || Date.current.year
        authorize Report, :generate?, policy_class: ReportPolicy
        ReportGeneratorJob.perform_later(year.to_i, current_tenant.id)
        # reports_data = Reports::AnnualCourtReportService.new(year: year, court: court).generate
        render_json :ok, 'Report generation started', nil
      end

      private

      def serialized_reports(reports)
        reports.map do |report|
          ReportSerializer.new(report).serializable_hash[:data][:attributes]
        end
      end

      def serialized_report(report)
        ReportSerializer.new(report).serializable_hash[:data][:attributes]
      end
    end
  end
end
