class AddUniqueIndexToSolidQueueJobs < ActiveRecord::Migration[8.0]
  def change
    add_index :solid_queue_jobs, :id, unique: true
  end
end
