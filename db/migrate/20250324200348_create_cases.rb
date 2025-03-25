class CreateCases < ActiveRecord::Migration[8.0]
  def change
    create_table :cases do |t|
      t.string :case_number
      t.string :registration_number
      t.string :judgement_number
      t.string :title
      t.text :summary
      t.integer :case_priority
      t.boolean :is_appeal, default: false
      t.boolean :is_enforced, default: false
      t.boolean :is_remanded, default: false
      t.boolean :is_reopened, default: false
      t.integer :case_status
      t.references :court, null: false, foreign_key: true
      t.references :case_subtype, null: true, foreign_key: true

      t.timestamps
    end
    add_index :cases, :case_number, unique: true
    add_index :cases, :registration_number, unique: true
    add_index :cases, :judgement_number, unique: true
    add_index :cases, :is_appeal
    add_index :cases, :is_enforced
    add_index :cases, :is_remanded
    add_index :cases, :is_reopened
    add_index :cases, :case_status
  end
end
