# frozen_string_literal: true

# Case Query Class
class CaseQuery
  def initialize(court_case)
    @case = court_case
  end

  def call
    hearings = @case.hearings.includes(:hearing_type, :case_documents, :case_evidences)
    case_file(hearings)
  end

  private

  def case_file(hearings)
    CaseFileSerializer.new(hearings, is_collection: true).serializable_hash[:data].pluck(:attributes)
  end
end
