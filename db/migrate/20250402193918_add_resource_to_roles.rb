class AddResourceToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :resource_type, :string
    add_column :roles, :resource_id, :integer
  end
end
