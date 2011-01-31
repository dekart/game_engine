require "spec_helper"

describe GiftReceipt do
  describe 'when receiving Facebook IDs for receint receipts' do
    before do
      @gift_receipt = Factory(:gift_receipt)
    end

    it 'should return empty array if sending delay is set to 0' do
      Setting.should_receive(:i).with(:gifting_repeat_send_delay).and_return(0)

      GiftReceipt.recent_facebook_ids.should == []
    end

    it 'should return facebook ids for gifts in time limit' do
      Timecop.travel((24.hours + 1.minute).ago) do
        @gift_receipt2 = Factory(:gift_receipt, :facebook_id => 111222333)
      end

      GiftReceipt.recent_facebook_ids.should == [987654321]
    end

    it 'should respect current scope' do
      @other_gift = Factory(:gift)
      @other_gift_receipt = Factory(:gift_receipt,
        :gift => @other_gift,
        :facebook_id => 111222333
      )

      GiftReceipt.recent_facebook_ids.should include(111222333, 987654321)

      GiftReceipt.scoped(:conditions => {:gift_id => @other_gift.id}).recent_facebook_ids.should == [111222333]
    end
  end

  describe 'when giving out item to character' do
    before do
      @character = Factory(:character)
      @gift_receipt = Factory(:gift_receipt, :facebook_id => @character.user.facebook_id)
    end

    it 'should mark receipt as accepted' do
      lambda{
        @gift_receipt.give_item!
      }.should change(@gift_receipt, :accepted).from(false).to(true)
    end

    it 'should assign receipt character' do
      lambda{
        @gift_receipt.give_item!
      }.should change(@gift_receipt, :character).from(nil).to(@character)
    end

    it 'should give item to character' do
      lambda{
        @gift_receipt.give_item!
      }.should change(@character.inventories, :count).from(0).to(1)

      @character.inventories.first.item.should == @gift_receipt.gift.item
      @character.inventories.first.amount.should == 1
    end

    it 'should save receipt' do
      @gift_receipt.give_item!
      @gift_receipt.should_not be_changed
    end

    it 'should save character' do
      @gift_receipt.give_item!

      @gift_receipt.character.should_not be_changed
    end
  end
end