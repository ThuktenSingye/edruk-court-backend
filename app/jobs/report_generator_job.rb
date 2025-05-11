# frozen_string_literal: true

# Report Generator Job
class ReportGeneratorJob < ApplicationJob
  queue_as :report_generation

  def perform(year, court_id)
    court = Court.find_by(id: court_id)
    report = court.reports.create!(year: year, report_status: :processing)

    # Generate report data
    reports_data = Reports::AnnualCourtReportService.new(year: year, court: court).generate

    # Generate charts
    chart_generator = Reports::ReportChartGenerator.new(data: reports_data, year: year)
    charts = chart_generator.generate

    # Configure WickedPDF options
    pdf_options = {
      page_size: 'A4',
      encoding: 'UTF-8',
      margin: { top: 20, bottom: 20, left: 20, right: 20 },
      print_media_type: true,
      javascript_delay: 1000
    }

    pie_chart_path = charts[:pie_chart].sub(Rails.public_path.to_s, '')
    bar_chart_path = charts[:bar_chart].sub(Rails.public_path.to_s, '')

    renderer = ActionController::Renderer.for(PdfRenderingsController)
    html = renderer.render(
      template: 'reports/show',
      layout: 'pdf',
      locals: {
        reports_data: reports_data[:case_statistic],
        pie_chart_path: pie_chart_path,
        bar_chart_path: bar_chart_path,
        court_type: court.court_type&.humanize&.downcase,
        year: year
      }
    )

    # Save HTML to a file for debugging
    debug_html_path = Rails.root.join('tmp/last_report.html')
    File.write(debug_html_path, html)
    Rails.logger.info("Saved debug HTML to #{debug_html_path}")

    # Generate PDF with the HTML
    pdf = WickedPdf.new.pdf_from_string(
      html,
      pdf_options
    )

    # Attach PDF to the report
    report.file.attach(
      io: StringIO.new(pdf),
      filename: "report_#{year}_#{court.id}.pdf",
      content_type: 'application/pdf'
    )

    # Update report status
    report.update(report_status: :completed)
  end
end
