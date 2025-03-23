class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :dzongkhag
      t.string :gewog
      t.string :street_address
      t.integer :address_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :addresses, [:user_id, :address_type], unique: true
  end
end
