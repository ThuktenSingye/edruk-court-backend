class RenameTypeToCourtTypeInCourts < ActiveRecord::Migration[8.0]
  def change
    rename_column :courts, :type, :court_type
  end
end
