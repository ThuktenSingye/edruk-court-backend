class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :cid_no
      t.string :phone_number
      t.string :house_no
      t.string :thram_no
      t.integer :age
      t.integer :gender
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :profiles, :cid_no, unique: true
  end
end
