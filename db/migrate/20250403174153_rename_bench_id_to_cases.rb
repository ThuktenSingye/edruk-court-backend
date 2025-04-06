class RenameBenchIdToCases < ActiveRecord::Migration[8.0]
  def change
    remove_column :cases, :bench_id_id, :integer
    add_reference :cases, :bench, foreign_key: { to_table: :courts }, index: true, null: true
  end
end
