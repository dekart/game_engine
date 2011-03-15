class CreateLoggedEvents < ActiveRecord::Migration
  def self.up
    create_table :logged_events do |t|
      t.string      :event_type

      t.references  :character
      t.integer     :level

      t.integer     :reference_id
      t.string      :reference_type
      t.integer     :reference_level

      t.integer     :amount
      
      t.integer     :experience

      t.integer     :basic_money, :limit => 8
      t.integer     :vip_money, :limit => 8

      t.integer     :attacker_damage
      t.integer     :victim_damage

      t.string      :string_value
      t.integer     :int_value

      t.datetime    :occurred_at
      t.timestamps
    end

    add_index :logged_events, :event_type
  end

  def self.down
    drop_table :logged_events
  end
end
