class CreateDocumentSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :document_signatures do |t|
      t.text :signature_data
      t.datetime :signed_at
      t.bigint :signer_id, null: false
      t.references :signable, polymorphic: true, null: false

      t.timestamps
    end

    add_index :document_signatures, :signer_id
    add_foreign_key :document_signatures, :case_participants, column: :signer_id
  end
end
