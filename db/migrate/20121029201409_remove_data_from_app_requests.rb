class RemoveDataFromAppRequests < ActiveRecord::Migration
  def up
    remove_column :app_requests, :data
  end

  def down
    add_column :app_requests, :data, :text
  end
end
