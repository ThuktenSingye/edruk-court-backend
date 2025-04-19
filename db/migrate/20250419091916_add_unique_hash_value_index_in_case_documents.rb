class AddUniqueHashValueIndexInCaseDocuments < ActiveRecord::Migration[8.0]
  def change
    add_index :case_documents, :hash_value, unique: true
  end
end
