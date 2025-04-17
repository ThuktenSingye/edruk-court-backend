class AddUniqueIndexToHashInCaseEvidence < ActiveRecord::Migration[8.0]
  def change
    add_index :case_evidences, [:hash_value, :hearing_id], unique: true
  end
end
