class AddUserToCaseDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :case_documents, :user, null: true, foreign_key: true
  end
end
