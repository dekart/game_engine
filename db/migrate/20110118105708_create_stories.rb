class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.string    :alias, :limit => 70, :null => false
      
      t.string    :title,       :limit => 200,  :null => false
      t.string    :description, :limit => 200,  :null => false
      t.string    :action_link, :limit => 50,   :null => false
      
      t.string    :image_file_name,                   :default => "", :null => false
      t.string    :image_content_type, :limit => 100, :default => "", :null => false
      t.integer   :image_file_size
      t.datetime  :image_updated_at

      t.text :payouts
      
      t.string :state, :limit => 50, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
