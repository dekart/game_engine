class CreateBosses < ActiveRecord::Migration
  def self.up
    create_table :bosses do |t|
      t.belongs_to :mission_group

      t.string  :name
      t.text    :description

      t.integer :health
      t.integer :attack
      t.integer :defence

      t.integer :ep_cost
      t.integer :experience

      t.text    :requirements
      t.text    :payouts

      t.string  :image_file_name
      t.string  :image_content_type
      t.integer :image_file_size

      t.integer :time_limit, :default => 48

      t.timestamps
    end

    create_table :boss_fights do |t|
      t.belongs_to :boss
      t.belongs_to :character

      t.integer   :health
      
      t.datetime  :expire_at

      t.string  :workflow_state, :limit => 50

      t.timestamps
    end
  end

  def self.down
    drop_table :bosses
    drop_table :boss_fights
  end
end
