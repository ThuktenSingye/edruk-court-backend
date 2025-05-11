class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :court, null: false, foreign_key: true
      t.references :generated_by, null: true, foreign_key: { to_table: :users }
      t.integer :report_status
      t.datetime :generated_at
      t.jsonb :metadata
      t.string :year

      t.timestamps
    end
  end
end
