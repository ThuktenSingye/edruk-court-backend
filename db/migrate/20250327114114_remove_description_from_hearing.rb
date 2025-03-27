class RemoveDescriptionFromHearing < ActiveRecord::Migration[8.0]
  def change
    remove_column :hearings, :description, :text
  end
end
