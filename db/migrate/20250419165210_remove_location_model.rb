class RemoveLocationModel < ActiveRecord::Migration[8.0]
  def change
    remove_column :courts, :location_id
    drop_table :locations
  end
end
