class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.integer  :owner_id
      t.string   :owner_type
      t.string   :style
      
      t.string   :image_file_name,    :default => "",                :null => false
      t.string   :image_content_type, :limit => 100, :default => "", :null => false
      t.integer  :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
