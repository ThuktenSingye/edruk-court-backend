class CreateCaseSubtypes < ActiveRecord::Migration[8.0]
  def change
    create_table :case_subtypes do |t|
      t.string :title
      t.references :case_type, null: false, foreign_key: true

      t.timestamps
    end

    add_index :case_subtypes, :title, unique: true
  end
end
