class MakeHelpRequestsPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :help_requests, :mission_id, :context_id
    
    add_column :help_requests, :context_type, :string, :limit => 30

    add_column :fights, :cause_type, :string, :limit => 30

    HelpRequest.update_all("context_type = 'Mission'")
    Fight.update_all("cause_type = 'Fight'", "cause_id IS NOT NULL")
  end

  def self.down
    HelpRequest.delete_all("context_type != 'Mission'")
    Fight.delete_all("cause_type != 'Fight'")

    rename_column :help_requests, :context_id, :mission_id

    remove_column :help_requests, :context_type

    remove_column :fights, :cause_type
  end
end
