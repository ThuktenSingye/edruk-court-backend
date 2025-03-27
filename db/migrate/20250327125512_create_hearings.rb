class CreateHearings < ActiveRecord::Migration[8.0]
  def change
    create_table :hearings do |t|
      t.integer :hearing_status
      t.references :case, null: false, foreign_key: true
      t.references :hearing_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
