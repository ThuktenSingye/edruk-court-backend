class RemoveUniqueIndexFromCases < ActiveRecord::Migration[8.0]
  def change
    remove_index :cases, :case_number if index_exists?(:cases, :case_number)
    remove_index :cases, :registration_number if index_exists?(:cases, :registration_number)
    remove_index :cases, :judgement_number if index_exists?(:cases, :judgement_number)
  end
end
