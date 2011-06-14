class CreateCreditPackages < ActiveRecord::Migration
  def self.up
    create_table :credit_packages do |t|
      t.integer :vip_money
      t.integer :price
      
      t.boolean :default
      
      t.string   "image_file_name",                        :default => "",     :null => false
      t.string   "image_content_type",      :limit => 100, :default => "",     :null => false
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
      
      
      t.string  :state, :limit => 30
      
      t.timestamps
    end
  end

  def self.down
    drop_table :credit_packages
  end
end
