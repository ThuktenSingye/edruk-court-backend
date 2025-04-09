class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hearing, null: false, foreign_key: true
      t.string :content

      t.timestamps
    end
  end
end
