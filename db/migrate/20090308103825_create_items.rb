class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :type, :limit => 30

      t.integer :level

      t.integer :basic_price
      t.integer :vip_price

      t.string  :name
      t.string  :description
      t.string  :placements

      t.text    :effects

      t.string  :image_file_name
      t.string  :image_content_type
      t.integer :image_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
