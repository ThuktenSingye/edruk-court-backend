class CreateHearingTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :hearing_types do |t|
      t.string :name

      t.timestamps
    end

    add_index :hearing_types, :name, unique: true
  end
end
