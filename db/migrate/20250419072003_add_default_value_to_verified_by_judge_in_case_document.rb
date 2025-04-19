class AddDefaultValueToVerifiedByJudgeInCaseDocument < ActiveRecord::Migration[8.0]
  def change
    change_column_default   :case_documents, :verified_by_judge, default: false
  end
end
