class AddAvailableForFriendsInviteToMonsterTypes < ActiveRecord::Migration
  def self.up
    add_column :monster_types, :available_for_friends_invite, :boolean, :default => true
  end

  def self.down
    remove_column :monster_types, :available_for_friends_invite
  end
end
