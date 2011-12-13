class CreateClanMembershipApplications < ActiveRecord::Migration
  def self.up
    create_table :clan_membership_applications do |t|
      t.integer :clan_id
      t.integer :character_id

      t.timestamps
    end
  end

  def self.down
    drop_table :clan_membership_applications
  end
end
