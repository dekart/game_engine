class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string  :content
      t.integer :min_level
      t.integer :amount_sent, :default => 0
      t.integer :last_recipient_id
      t.string  :state, :limit => 50, :default => "", :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
