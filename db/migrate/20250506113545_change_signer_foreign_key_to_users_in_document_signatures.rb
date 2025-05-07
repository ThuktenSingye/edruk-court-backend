class ChangeSignerForeignKeyToUsersInDocumentSignatures < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :document_signatures, column: :signer_id
    add_foreign_key :document_signatures, :users, column: :signer_id
  end
end
