class AddCaseIdToCaseDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :case_documents, :case, null: true, foreign_key: true
  end
end
