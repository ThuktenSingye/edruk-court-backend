# frozen_string_literal: true

# Case Query Class
class CaseQuery
  def initialize(court_case)
    @case = court_case
  end

  def call(current_user)
    hearings = @case.hearings.includes(:hearing_type, :case_documents, :case_evidences)
    case_file(hearings, current_user)
  end

  private

  def case_file(hearings, current_user)
    CaseFileSerializer.new(hearings, params: { current_user: current_user },
                                     is_collection: true).serializable_hash[:data].pluck(:attributes)
  end
end
