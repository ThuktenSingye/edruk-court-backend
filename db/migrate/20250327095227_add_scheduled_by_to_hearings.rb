class AddScheduledByToHearings < ActiveRecord::Migration[8.0]
  def change
    add_reference :hearings, :scheduled_by, null: false, foreign_key: { to_table: :users }, index: true
  end
end
