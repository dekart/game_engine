class AddTargetAndExpiredAtToAppRequests < ActiveRecord::Migration
  def self.up
    change_table :app_requests do |t|
      t.timestamp :expired_at
      t.integer :target_id
      t.column :target_type, :string, :limit => 50
    end
    
    add_index :app_requests, [:target_id, :target_type]
  end

  def self.down
    change_table :app_requests do |t|
      t.remove :expired_at
      t.remove :target_id
      t.remove :target_type
    end
  end
end