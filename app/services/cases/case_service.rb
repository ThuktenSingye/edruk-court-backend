# frozen_string_literal: true

module Cases
  # Service Class for Case Controller
  class CaseService
    def initialize(params)
      @params = params
    end

    def case_statistics
      StatisticsSerializer.new(case_stats_data).serializable_hash[:data][:attributes]
    end

    private

    def case_stats_data
      {
        total: total_cases,
        civil: count_by_case_type('Civil'),
        criminal: count_by_case_type('Criminal'),
        others: count_by_case_type('Other'),
        active: count_by_status(:active),
        decided: count_by_status(:decided),
        appeal: count_appeals
      }
    end

    def total_cases
      @params.count
    end

    def count_by_case_type(type)
      @params.joins(:case_type).where(case_types: { title: type }).count
    end

    def count_by_status(status)
      @params.where(case_status: status).count
    end

    def count_appeals
      @params.where(is_appeal: true).count
    end
  end
end
