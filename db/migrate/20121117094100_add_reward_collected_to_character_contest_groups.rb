class AddRewardCollectedToCharacterContestGroups < ActiveRecord::Migration
  def up
    change_table :character_contest_groups do |t|
      t.boolean :reward_collected, :default => false
    end

    CharacterContestGroup.update_all "reward_collected = 1"

    change_table :contests do |t|
      t.boolean :finish_notification_sent, :default => false
    end

    Contest.where("state='finished'").update_all("state='visible'")
    Contest.finished.update_all "finish_notification_sent = 1"
  end

  def down
    change_table :character_contest_groups do |t|
      t.remove :reward_collected
    end

    change_table :contests do |t|
      t.remove :finish_notification_sent
    end
  end
end
