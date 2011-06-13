class CreateCreditPackages < ActiveRecord::Migration
  def self.up
    create_table :credit_packages do |t|
      t.integer :vip_money
      t.integer :price
      
      t.string  :state, :limit => 30
      
      t.timestamps
    end
  end

  def self.down
    drop_table :credit_packages
  end
end
