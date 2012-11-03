class AddUserAgentToUser < ActiveRecord::Migration
  def up
    add_column :users, :last_visit_user_agent, :string, :limit => 250, :null => false, :default => ''
  end

  def down
    remove_column :users, :last_visit_user_agent
  end
end
