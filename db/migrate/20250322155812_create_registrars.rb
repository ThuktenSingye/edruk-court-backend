class CreateRegistrars < ActiveRecord::Migration[8.0]
  def change
    create_table :registrars do |t|
      t.references :user, null: false, foreign_key: true
      t.belongs_to :court, null: false, foreign_key: true

      t.timestamps
    end
  end
end
