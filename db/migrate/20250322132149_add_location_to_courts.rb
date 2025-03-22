class AddLocationToCourts < ActiveRecord::Migration[8.0]
  def change
    add_reference :courts, :location, foreign_key: true, null: false
  end
end
