class AllowDefaultValue < ActiveRecord::Migration[8.0]
  def change
    change_column_default :cases, :case_status, from: nil, to: 0
    change_column_default :cases, :case_priority, from: nil, to: 0
    change_column_default :hearings, :hearing_status, from: nil, to: 0
    change_column_default :hearing_schedules, :schedule_status, from: nil, to: 0
    change_column_default :case_documents, :document_status, from: nil, to: 0
    change_column_default :case_evidences, :evidence_status, from: nil, to: 0
  end
end
