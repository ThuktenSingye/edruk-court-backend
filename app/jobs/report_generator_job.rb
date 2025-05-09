# frozen_string_literal: true

# Report Generator Job
class ReportGeneratorJob < ApplicationJob
  queue_as :report_generation

  def perform(year, court_id)
    # court = Court.find_by(id: court_id)
    # Reports::AnnualCourtReportService.new(year: year, court: court).generate
    # Do something later
  end
end
