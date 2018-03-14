class AddIndexForJobsUpdatedAt < ActiveRecord::Migration
  def change
      add_index :jobs, :updated_at
  end
end
