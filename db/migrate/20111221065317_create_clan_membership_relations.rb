class CreateClanMembershipRelations < ActiveRecord::Migration
  def self.up
    create_table :clan_membership_invitations do |t|
      t.integer :clan_id
      t.integer :character_id

      t.timestamps
    end
  end

  def self.down
    drop_table :clan_membership_invitations
  end
end
