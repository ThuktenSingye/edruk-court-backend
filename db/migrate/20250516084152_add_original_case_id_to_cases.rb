class AddOriginalCaseIdToCases < ActiveRecord::Migration[8.0]
  def change
    add_reference :cases, :original_case, null: true, foreign_key: { to_table: :cases }
  end
end
