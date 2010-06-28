class AddPermissionsToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :permission_email
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :permission_email
    end
  end
end
