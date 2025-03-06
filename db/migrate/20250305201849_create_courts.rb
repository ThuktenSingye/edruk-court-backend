class CreateCourts < ActiveRecord::Migration[8.0]
  def change
    create_table :courts do |t|
      t.string :name
      t.integer :type
      t.string :email
      t.string :contact_no
      t.string :subdomain, null: true
      t.string :domain, null: true
      t.references :parent_court, foreign_key: { to_table: :courts }, null: true
      t.timestamps
    end

    add_index :courts, :subdomain, unique: true
    add_index :courts, :domain, unique: true
  end
end
