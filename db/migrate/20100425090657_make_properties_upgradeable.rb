class MakePropertiesUpgradeable < ActiveRecord::Migration
  def self.up
    change_table :properties do |t|
      t.rename :amount, :level

      t.change :level, :integer, :default => 1

      t.datetime :collected_at
    end

    change_table :property_types do |t|
      t.rename :purchase_limit, :upgrade_limit
      t.rename :inflation, :upgrade_cost_increase

      t.integer :collect_period, :default => 1
    end

    Setting[:property_upgrade_limit] = Setting[:property_maximum_amount]

    Setting[:property_maximum_amount] = nil
  end

  def self.down
    change_table :properties do |t|
      t.rename :level, :amount

      t.change :amount, :integer, :default => 0

      t.remove :collected_at
    end

    change_table :property_types do |t|
      t.rename :upgrade_limit, :purchase_limit
      t.rename :upgrade_cost_increase, :inflation

      t.remove :collect_period
    end

    Setting[:property_maximum_amount] = Setting[:property_upgrade_limit]

    Setting[:property_upgrade_limit] = nil
  end
end
