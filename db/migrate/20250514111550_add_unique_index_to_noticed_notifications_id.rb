class AddUniqueIndexToNoticedNotificationsId < ActiveRecord::Migration[8.0]
  def change
    add_index :noticed_notifications, :id, unique: true
  end
end
