# frozen_string_literal: true

module Reports
  # Service class for annual report generation
  class AnnualCourtReportService
    def initialize(year:, court:)
      @year = year
      @court = court
    end

    def generate
      if @court.supreme?
        generate_supreme_court_annual_report
      else
        generate_annual_court_report
      end
    end

    private

    def generate_supreme_court_annual_report; end
    def generate_annual_court_report; end

    def national_case_overview
      {
        criminal: count_by_case_type('Criminal'),
        civil: count_by_case_type('Civil'),
        other: count_by_case_type('Other')
      }
    end

    def national_case_statistics
      {
        supreme: supreme_court_case_statistics,
        high: high_court_case_statistics,
        dzongkhag: dzongkhag_court_case_statistics,
        dungkhag: dungkhag_court_case_statistics
      }
    end

    def supreme_court_case_overview
      supreme_courts ||= Court.supreme_courts

      total_cases = 0
      total_decided = 0
      total_pending = 0

      supreme_courts.each do |supreme_court|
        total_cases += supreme_court.cases.count
        total_decided += decided_case(supreme_court)
        total_pending += pending_case(supreme_court)
      end
    end

    def high_court_case_overview

      high_courts ||= Court.high_courts

      total_cases = total_decided = total_pending = total_appeal = total_enforced = 0

      high_courts.each do |high_court|
        total_cases += total_cases(high_court)
        total_decided += decided_case(high_court)
        total_pending += pending_case(high_court)
        total_appeal += appeal_case(high_court)
        total_enforced += enforced_case(high_court)
      end
    end

    def dzongkhag_court_case_overview

    end

    def dungkhag_court_case_overview

    end

    def supreme_court_case_statistics
      supreme_courts ||= courts(:supreme)
      supreme_courts.map do |supreme_court|
        {
          total: total_case(supreme_court),
          decided: decided_case(supreme_court),
          pending: pending_case(supreme_court),
        }
      end
    end

    def high_court_case_statistics
      high_courts ||= courts(:high)
      high_courts.map do |high_court|
        {
          total: total_case(high_court),
          decided: decided_case(high_court),
          pending: pending_case(high_court),
          appeal: appeal_case(high_court),
          enforced: enforced_case(high_court)
        }
      end
    end

    def dzongkhag_court_case_statistics
      dzongkhag_courts ||= courts(:dzongkhag)
      dzongkhag_courts.map do |dzongkhag_court|
        {
          total: total_case(dzongkhag_court),
          decided: decided_case(dzongkhag_court),
          pending: pending_case(dzongkhag_court),
          appeal: appeal_case(dzongkhag_courts),
          enforced: enforced_case(dzongkhag_court)
        }
      end
    end

    def dungkhag_court_case_statistics
      dungkhag_courts ||= courts(:dungkhag)
      dungkhag_courts.map do |dungkhag_court|
        {
          total: total_case(dungkhag_court),
          decided: decided_case(dungkhag_court),
          pending: pending_case(dungkhag_court),
          appeal: appeal_case(dungkhag_court),
          enforced: enforced_case(dungkhag_court)
        }
      end
    end

    def count_by_case_type(type)
      Case.joins(:case_type).where(case_types: { title: type }).count
    end

    def courts(court_type)
      result_courts = []
      courts = Court.where(court_type: court_type)
      courts.map do |court|
        if court.bench_exist?
          benches = court.child_courts
          result_courts.concat(Array(benches))
        else
          result_courts << court
        end
      end
    end

    def decided_case(court)
      court.cases.where(case_status: :closed).count
    end

    def pending_case(court)
      court.cases.where(case_status: :pending).count
    end

    def appeal_case(court)
      court.cases.where(is_appeal: true).count
    end

    def enforced_case(court)
      court.cases.where(is_enfored: true).count
    end

    def total_case(court)
      court.cases.count
    end
  end
end
