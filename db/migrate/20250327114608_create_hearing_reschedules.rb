class CreateHearingReschedules < ActiveRecord::Migration[8.0]
  def change
    create_table :hearing_reschedules do |t|
      t.datetime :original_date, null: false
      t.datetime :new_date, null: false
      t.text :reason
      t.references :hearing, null: false, foreign_key: true
      t.references :rescheduled_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
