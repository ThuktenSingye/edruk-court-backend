class AddUniqueHashValueIndexInCaseEvidence < ActiveRecord::Migration[8.0]
  def change
    add_index :case_evidences, :hash_value, unique: true
  end
end
