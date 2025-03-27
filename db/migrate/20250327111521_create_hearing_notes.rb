class CreateHearingNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :hearing_notes do |t|
      t.text :content, null: false
      t.references :hearing, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
