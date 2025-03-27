class AddCaseTypeToCase < ActiveRecord::Migration[8.0]
  def change
    add_reference :cases, :case_type, null: true, foreign_key: true
  end
end
