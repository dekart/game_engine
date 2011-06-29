class AddIndicesOnFightsUsersMonsterFights < ActiveRecord::Migration
  def self.up
    add_index :app_requests, [:target_id, :target_type]
    
    add_index :monsters, [:defeated_at, :expire_at]
    
    add_index :users, :created_at
    
    add_index :vip_money_operations, [:type, :reference_type, :reference_id], :name => 'index_on_name_ref_type_ref_id'
  end

  def self.down
  end
end
