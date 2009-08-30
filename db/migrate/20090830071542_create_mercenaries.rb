class CreateMercenaries < ActiveRecord::Migration
  def self.up
    add_column :relations, :type, :string
    add_column :relations, :name, :string

    Relation.update_all "type='FriendRelation'"
  end

  def self.down
    remove_column :relations, :type
    remove_column :relations, :name
  end
end
