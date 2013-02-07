class RemoveTips < ActiveRecord::Migration
  def up
    drop_table :tips

    remove_column :users, :show_tips
  end

  def down
    create_table "tips" do |t|
      t.text     "text"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state",      :limit => 50
    end

    add_column :users, :show_tips, :boolean, :default => true
  end
end
