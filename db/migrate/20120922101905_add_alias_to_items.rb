class AddAliasToItems < ActiveRecord::Migration
  def up
    change_table :items do |t|
      t.string :alias, :null => false, :default => ""
    end

    Item.where("alias = ''").update_all "alias = CONCAT('item_', id)"
  end

  def down
    remove_column :items, :alias
  end
end
