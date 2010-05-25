class UsePayoutsInItems < ActiveRecord::Migration
  def self.up
    change_table :items do |t|
      t.text :payouts
    end

    Rake::Task["app:maintenance:use_payouts_for_item_effects"].execute

    change_table :items do |t|
      t.remove :effects
      t.remove :usage_limit
    end
  end

  def self.down
    change_table :items do |t|
      t.remove :payouts

      t.text    :effects
      t.integer :usage_limit
    end
  end
end
