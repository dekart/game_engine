class MakeTotalMoneyBigint < ActiveRecord::Migration
  def self.up
    change_table :characters do |t|
      t.change :total_money, :bigint, :default => 0
    end
  end

  def self.down
    change_table :characters do |t|
      t.change :total_money, :integer, :default => 0
    end
  end
end
