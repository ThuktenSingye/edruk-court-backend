class RenameUserRolesToUsersRoles < ActiveRecord::Migration[8.0]
  def change
    rename_table :user_roles, :users_roles
  end
end
