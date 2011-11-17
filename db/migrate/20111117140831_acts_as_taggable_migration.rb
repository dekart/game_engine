class ActsAsTaggableMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string
    end
    
    create_table :taggings do |t|
      t.column :tag_id, :integer
      t.column :taggable_id, :integer
      
      # You should make sure that the column created is
      # long enough to store the required class names.
      t.column :taggable_type, :string
      
      t.column :created_at, :datetime
    end
    
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
    
    %w{item_groups items mission_groups missions property_types monster_types item_collections tips}.each do |table|
      add_column(table, :cached_tag_list, :string)
    end
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags

    %w{item_groups items mission_groups missions property_types monster_types item_collections tips}.each do |table|
      remove_column(table, :cached_tag_list)
    end
  end
end
