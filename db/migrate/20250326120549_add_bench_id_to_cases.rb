class AddBenchIdToCases < ActiveRecord::Migration[8.0]
  def change
    add_reference :cases, :bench_id, foreign_key: { to_table: :courts }, index: true, null: true
  end
end
