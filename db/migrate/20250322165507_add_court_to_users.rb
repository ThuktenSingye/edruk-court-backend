class AddCourtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :court, null: true, foreign_key: true
  end
end
