class CreateHearingSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :hearing_schedules do |t|
      t.datetime :scheduled_date
      t.integer :schedule_status
      t.text :reschedule_reason
      t.references :hearing, null: false, foreign_key: true
      t.references :scheduled_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
