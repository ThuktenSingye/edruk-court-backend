class CreateCaseParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :case_participants do |t|
      t.references :user, null: true, foreign_key: true
      t.references :case, null: true, foreign_key: true
      t.references :role, null: true, foreign_key: true

      t.timestamps
    end
  end
end
