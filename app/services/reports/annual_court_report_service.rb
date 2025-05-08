# frozen_string_literal: true

module Reports
  # Service class for annual report generation
  # rubocop:disable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize
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

    def generate_supreme_court_annual_report
      {
        cases: national_case_type_counts,
        case_overview: national_case_overview,
        case_statistic: national_case_statistics
      }
    end

    def generate_annual_court_report
      {
        cases: court_case_type_counts,
        cases_overview: case_overview,
        court_case_statistic: generate_court_report
      }
    end

    def national_case_type_counts
      {
        criminal: count_by_case_type('Criminal'),
        civil: count_by_case_type('Civil'),
        other: count_by_case_type('Other')
      }
    end

    def national_case_overview
      {
        supreme: supreme_court_case_overview,
        high: high_court_case_overview,
        dzongkhag: dzongkhag_court_case_overview,
        dungkhag: dungkhag_court_case_overview
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
      court_case_overview(:supreme, metrics: %i[total_case decided_case pending_case])
    end

    def high_court_case_overview
      court_case_overview(:high, metrics: %i[total_case decided_case pending_case appeal_case enforced_case])
    end

    def dzongkhag_court_case_overview
      court_case_overview(:dzongkhag,
                          metrics: %i[total_case decided_case pending_case appeal_case enforced_case])
    end

    def dungkhag_court_case_overview
      court_case_overview(:dungkhag,
                          metrics: %i[total_case decided_case pending_case appeal_case enforced_case])
    end

    def court_case_overview(court_type,
                            metrics: %i[total_case decided_case pending_case appeal_case enforced_case])
      legal_courts ||= courts(court_type)
      result = Hash.new(0)

      legal_courts.each do |court|
        metrics.each do |metric|
          result[metric] += send(metric, court)
        end
      end

      result
    end

    def supreme_court_case_statistics
      supreme_courts ||= courts(:supreme)
      result = {}
      supreme_courts.map do |supreme_court|
        result[supreme_court.name] = {
          opening_balance: opening_balance(supreme_court),
          registered: registered_case(supreme_court),
          total: total_case(supreme_court),
          decided: decided_case(supreme_court),
          pending: pending_case(supreme_court)
        }
      end
    end

    def high_court_case_statistics
      high_courts ||= courts(:high)
      result = {}
      high_courts.map do |high_court|
        result[high_court.name] = {
          opening_balance: opening_balance(high_court),
          registered: registered_case(high_court),
          total: total_case(high_court),
          decided: decided_case(high_court),
          pending: pending_case(high_court),
          appeal: appeal_case(high_court),
          enforced: enforced_case(high_court)
        }
      end
      result
    end

    def dzongkhag_court_case_statistics
      dzongkhag_courts ||= courts(:dzongkhag)
      result = {}
      dzongkhag_courts.map do |dzongkhag_court|
        result[dzongkhag_court.name] = {
          opening_balance: opening_balance(dzongkhag_court),
          registered: registered_case(dzongkhag_court),
          total: total_case(dzongkhag_court),
          decided: decided_case(dzongkhag_court),
          pending: pending_case(dzongkhag_court),
          appeal: appeal_case(dzongkhag_court), # Fixed: was dzongkhag_courts (plural)
          enforced: enforced_case(dzongkhag_court)
        }
      end
      result
    end

    def dungkhag_court_case_statistics
      dungkhag_courts ||= courts(:dungkhag)
      result = {}
      dungkhag_courts.map do |dungkhag_court|
        result[dungkhag_court.name] = {
          opening_balance: opening_balance(dungkhag_court),
          registered: registered_case(dungkhag_court),
          total: total_case(dungkhag_court),
          decided: decided_case(dungkhag_court),
          pending: pending_case(dungkhag_court),
          appeal: appeal_case(dungkhag_court),
          enforced: enforced_case(dungkhag_court)
        }
      end
      result
    end

    # court report for current court
    def court_case_type_counts
      {
        criminal: court_count_by_case_type('Criminal'),
        civil: court_count_by_case_type('Civil'),
        other: court_count_by_case_type('Other')
      }
    end

    def count_by_case_type(type)
      Case.joins(:case_type).where(case_types: { title: type }).count
    end

    def court_count_by_case_type(type)
      @court.cases.joins(:case_type).where(case_types: { title: type }).count
    end

    def bench_courts
      result_courts = []
      if @court.bench_exist?
        benches = @court.child_courts
        result_courts.concat(benches)
      else
        result_courts << court
      end
      result_courts
    end

    def case_overview
      result_courts = bench_courts
      total_cases = total_decided = total_pending = total_appeal = total_enforced = 0
      result_courts.each do |court|
        total_cases += total_case(court)
        total_decided += decided_case(court)
        total_pending += pending_case(court)
        total_appeal += appeal_case(court)
        total_enforced += enforced_case(court)
      end
      {
        total: total_cases,
        decided: total_decided,
        pending: total_pending,
        appeal: total_appeal,
        enforced: total_enforced
      }
    end

    def generate_court_report
      result_courts = @court.bench_exist? ? @court.child_courts : [@court]

      result_courts.to_h do |court|
        court_report = (1..12).to_h do |month|
          start_date = Date.new(@year, month, 1).beginning_of_day
          end_date = start_date.end_of_month.end_of_day
          month_name = start_date.strftime('%B')

          month_report = court.users.with_role(:Clerk).to_h do |clerk|
            clerk_name = "#{clerk.profile.first_name} #{clerk.profile.last_name}"
            [clerk_name, monthly_clerk_stats(clerk, start_date, end_date)]
          end

          [month_name, month_report]
        end

        [court.name, court_report]
      end
    end

    def monthly_clerk_stats(clerk, start_date, end_date)
      @clerk_cases ||= ::Case.joins(:case_participants).where(case_participants: { user_id: clerk.id,
                                                                                   role_id: clerk_role_id })
      {
        opening_balance: clerk_opening_balance(@clerk_cases, start_date),
        registered: clerk_registered_cases(@clerk_cases, start_date, end_date),
        decided: clerk_decided_cases(@clerk_cases, start_date, end_date),
        appeal: clerk_appeal_cases(@clerk_cases, start_date, end_date),
        pending: clerk_pending_cases(@clerk_cases, start_date, end_date)
      }
    end

    def clerk_opening_balance(cases, start_date)
      cases.where(case_status: :active)
           .where(cases: { created_at: ...start_date })
           .distinct
           .count
    end

    def clerk_registered_cases(cases, start_date, end_date)
      cases.where(created_at: start_date..end_date).distinct.count
    end

    def clerk_decided_cases(cases, start_date, end_date)
      cases.where(case_status: %i[dismissed withdrawn settled closed])
           .where(updated_at: start_date..end_date)
           .distinct
           .count
    end

    def clerk_appeal_cases(cases, start_date, end_date)
      cases.where(is_appeal: true)
           .where(updated_at: start_date..end_date)
           .distinct
           .count
    end

    def clerk_pending_cases(cases, start_date, end_date)
      cases.where(case_status: :pending)
           .where(cases: { created_at: ...start_date })
           .where.not(id: cases.where(case_status: %i[dismissed withdrawn settled closed])
                               .where(updated_at: start_date..end_date)
                               .select(:id))
           .distinct
           .count
    end

    def clerk_role_id
      Role.where(name: 'Clerk').pluck(:id)
    end

    def courts(court_type)
      result_courts = []
      courts = Court.where(court_type: court_type)
      courts.map do |court|
        if court.bench_exist?
          benches = court.child_courts
          result_courts.concat(benches)
        else
          result_courts << court
        end
      end

      result_courts
    end

    def registered_case(court)
      start_date = Date.new(@year, 1, 1).beginning_of_day
      end_date = Date.new(@year, 12, 31).end_of_day
      court.cases.where(created_at: start_date..end_date).count
    end

    def opening_balance(court)
      start_of_year = Date.new(@year.to_i, 1, 1)
      court.cases.where(case_status: 'active').where(created_at: ...start_of_year).count
    end

    def decided_case(court)
      court.cases.where(case_status: %i[dismissed withdrawn settled closed]).count
    end

    def pending_case(court)
      court.cases.where(case_status: :pending).count
    end

    def appeal_case(court)
      court.cases.where(is_appeal: true).count
    end

    def enforced_case(court)
      court.cases.where(is_enforced: true).count
    end

    def total_case(court)
      court.cases.count
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/MethodLength, Metrics/AbcSize
end
