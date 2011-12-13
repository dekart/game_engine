class ModifyTotalScore < ActiveRecord::Migration
  def self.up
    change_column :characters, :total_score, :bigint
  end

  def self.down
    change_column :characters, :total_score, :integer
  end
end
