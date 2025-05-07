class AllowNullHashValueInCaseDocuments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :case_documents, :hash_value, true
    remove_index :case_documents, column: :hash_value
  end
end
