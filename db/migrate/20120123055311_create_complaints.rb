class CreateComplaints < ActiveRecord::Migration
  def self.up
    create_table :complaints do |t|
      t.string  :cause
      t.text    :description
      
      t.integer :owner_id
      t.integer :offender_id 
      
      t.string  :state, :limit => 50
      
      t.timestamps
    end
  end

  def self.down
    drop_table :complaints
  end
end
