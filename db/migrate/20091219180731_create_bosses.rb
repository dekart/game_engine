class CreateBosses < ActiveRecord::Migration
  def self.up
    create_table :bosses do |t|
      t.belongs_to :mission_group

      t.string  :name
      t.text    :description

      t.integer :health

      t.integer :ep_cost
      t.integer :experience
      
      t.text    :requirements
      t.text    :payouts

      t.string  :image_file_name
      t.string  :image_content_type
      t.integer :image_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :bosses
  end
end
