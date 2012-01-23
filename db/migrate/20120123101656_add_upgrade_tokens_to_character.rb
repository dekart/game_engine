class AddUpgradeTokensToCharacter < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.integer  :upgrade_tokens, :default => 0
    end
  end

  def self.down
    change_table :characters do |t|
      t.remove   :upgrade_tokens
    end
  end
end
