class AddCourtToHearing < ActiveRecord::Migration[8.0]
  def change
    add_reference :hearings, :court, null: false, foreign_key: true
  end
end
