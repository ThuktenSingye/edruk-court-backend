class AllowNullvalueToJudgementAndCaseNumber < ActiveRecord::Migration[8.0]
  def change
    change_column_null :cases, :case_number, true
    change_column_null :cases, :judgement_number, true
  end
end
