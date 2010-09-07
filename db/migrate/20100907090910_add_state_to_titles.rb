class AddStateToTitles < ActiveRecord::Migration
  def self.up
    change_table :titles do |t|
      t.string :state, :limit => 50
    end

    Title.update_all 'state = "visible"'
  end

  def self.down
    change_table :titles do |t|
      t.remove :state
    end
  end
end
