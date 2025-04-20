class CreateJurisdictions < ActiveRecord::Migration[8.0]
  def change
    create_table :jurisdictions do |t|
      t.string :name
      t.integer :jurisdiction_type
      t.integer :parent_id
      t.references :court, null: false, foreign_key: true

      t.timestamps
    end
  end
end
