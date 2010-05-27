class AddAcceptedAndFacebookIdToGiftReceipts < ActiveRecord::Migration
  def self.up
    add_column :gift_receipts, :accepted, :boolean, :null => false, :default => false
    add_column :gift_receipts, :facebook_id, :integer, :limit => 6
    GiftReceipt.update_all 'accepted = 1'
  end

  def self.down
    remove_column :gift_receipts, :facebook_id
    remove_column :gift_receipts, :accepted
  end
end
