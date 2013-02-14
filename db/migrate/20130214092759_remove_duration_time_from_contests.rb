class RemoveDurationTimeFromContests < ActiveRecord::Migration
  def up
    remove_column :contests, :duration_time
  end

  def down
    add_column :contests, :duration_time
  end
end
