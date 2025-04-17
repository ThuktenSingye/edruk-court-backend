class CreateCaseDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :case_documents do |t|
      t.string :hash_value
      t.references :hearing, null: false, foreign_key: true
      t.boolean :verified_by_judge
      t.datetime :verified_at
      t.integer :document_status

      t.timestamps
    end
  end
end
