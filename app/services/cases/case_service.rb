# frozen_string_literal: true

module Cases
  # Service Class for Case Controller
  class CaseService
    def initialize(params)
      @params = params
    end

    def case_statistics
      stats_data = {
        total: @params.count,
        civil: @params.where(case_type: 'Civil').count,
        criminal: @params.where(case_type: 'Criminal').count,
        others: @params.where(case_type: 'Other').count,
        active: @params.where(case_status: :active).count,
        decided: @params.where(case_status: :decided).count,
        appeal: @params.where(is_appeal: true).count
      }
      StatisticsSerializer.new(stats_data).serializable_hash
    end
  end
end
