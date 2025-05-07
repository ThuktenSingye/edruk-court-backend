class CreateOrderRecipientCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :order_recipient_courts do |t|
      t.references :court_order, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.datetime :read_at
      t.integer :read_status

      t.timestamps
    end
  end
end
