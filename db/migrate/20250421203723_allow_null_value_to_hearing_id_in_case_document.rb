class AllowNullValueToHearingIdInCaseDocument < ActiveRecord::Migration[8.0]
  def change
    change_column_null :case_documents, :hearing_id, true
  end
end
