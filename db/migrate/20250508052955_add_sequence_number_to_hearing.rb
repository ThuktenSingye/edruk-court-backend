class AddSequenceNumberToHearing < ActiveRecord::Migration[8.0]
  def change
    add_column :hearings, :sequence_number, :integer, default: 1, null: true
  end
end
