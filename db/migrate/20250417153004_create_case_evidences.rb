class CreateCaseEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :case_evidences do |t|
      t.string :hash_value
      t.references :hearing, null: false, foreign_key: true
      t.boolean :verified_by_judge
      t.datetime :verified_at
      t.integer :evidence_status
      t.string :file_type
      t.boolean :is_encrypted
      t.string :iv
      t.string :auth_tag
      t.string :encrypted_key

      t.timestamps
    end
  end
end
