class CreateCaseTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :case_types do |t|
      t.string :title

      t.timestamps
    end
    add_index :case_types, :title, unique: true
  end
end
