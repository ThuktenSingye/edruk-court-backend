class AllowNullValueInCaseParticipants < ActiveRecord::Migration[8.0]
  def change
    change_column_null :case_participants, :user_id, true
    change_column_null :case_participants, :role_id, true
  end
end
