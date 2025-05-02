class AddColumnToCaseParticipantTable < ActiveRecord::Migration[8.0]
  def change
    add_column :case_participants, :first_name, :string, null: true
    add_column :case_participants, :last_name, :string, null: true
    add_column :case_participants, :email, :string, null: true
    add_column :case_participants, :phone_number, :string
    add_column :case_participants, :cid_no, :string
    add_column :case_participants, :address_data, :jsonb, default: []
  end
end
