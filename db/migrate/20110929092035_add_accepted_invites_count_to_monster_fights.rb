class AddAcceptedInvitesCountToMonsterFights < ActiveRecord::Migration
  def self.up
    add_column :monster_fights, :accepted_invites_count, :integer, :default => 0
  end

  def self.down
    remove_column :monster_fights, :accepted_invites_count
  end
end
