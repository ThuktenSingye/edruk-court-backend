class CreateCourtOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :court_orders do |t|
      t.text :message
      t.references :case, null: true, foreign_key: true
      t.string :order_type
      t.integer :issuance_court_id
      t.integer :issuing_user_id

      t.timestamps
    end

    add_foreign_key :court_orders, :courts, column: :issuance_court_id
    add_foreign_key :court_orders, :users, column: :issuing_user_id
  end
end
