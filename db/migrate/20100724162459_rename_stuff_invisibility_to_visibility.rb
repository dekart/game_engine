class RenameStuffInvisibilityToVisibility < ActiveRecord::Migration
  def self.up
    rename_table :stuff_invisibilities, :visibilities

    change_table :visibilities do |t|
      t.rename :stuff_id, :target_id
      t.rename :stuff_type, :target_type
    end
  end

  def self.down
    rename_table :visibilities, :stuff_invisibilities
  end
end
