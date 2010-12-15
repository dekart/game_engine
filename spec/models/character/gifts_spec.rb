require 'spec_helper'

describe Character do
  describe 'when checking if character has unaccepted gifts' do
    before do
      @character = Factory(:character)
    end
    
    it 'should return true if there are some unaccepted gifts for them' do
      @gift_receipt = Factory(:gift_receipt, :facebook_id => 123456789)

      @character.gifts.has_unaccepted?.should be_true
    end

    it 'should return false if all gifts are currently accepted' do
      @gift_receipt = Factory(:gift_receipt, :facebook_id => 123456789, :accepted => true)

      @character.gifts.has_unaccepted?.should be_false
    end

    it 'should return false if there are gifts for others but not them' do
      @gift_receipt = Factory(:gift_receipt, :facebook_id => 987654321)

      @character.gifts.has_unaccepted?.should be_false
    end
  end

  describe 'when accepting gift' do
    before do
      @user = Factory(:user, :facebook_id => 987654321)
      @character = Factory(:character, :user => @user)
      @gift = Factory(:gift)
      @gift_receipt = Factory(:gift_receipt, :gift => @gift, :facebook_id => 987654321)
    end

    describe 'when ID is passed' do
      it 'should give item to character' do
        lambda{
          @character.gifts.accept!(@gift.id)
        }.should change(@character.inventories, :count).from(0).to(1)

        @character.inventories.first.item.should == @gift.item
        @character.inventories.first.amount.should == 1
      end

      it 'should mark gift rececipt as accepted' do
        @character.gifts.accept!(@gift.id)

        @gift_receipt.reload.accepted.should be_true
      end

      it 'should return an array with the gift' do
        @character.gifts.accept!(@gift.id).should == [@gift]
      end

      it 'should assign received inventory to gift' do
        @character.gifts.accept!(@gift.id).first.inventory.should == @character.inventories.first
      end

      it 'should return empty array if there is no gift with passed ID' do
        @character.gifts.accept!(123456789).should == []
      end

      it 'should return empty array if gift was already accepted' do
        @gift_receipt.update_attribute(:accepted, true)

        @character.gifts.accept!(@gift.id).should == []
      end

      it 'should return empty array if gift was sent to other character' do
        @other_gift = Factory(:gift)
        @other_receipt = Factory(:gift_receipt, :gift => @other_gift, :facebook_id => 111222333)

        lambda{
          @character.gifts.accept!(@other_gift.id).should == []
        }.should_not change(@character.inventories, :count)
      end
    end

    describe 'when :all is passed' do
      before do
        @other_gift = Factory(:gift)
        @other_receipt = Factory(:gift_receipt, :gift => @other_gift, :facebook_id => 987654321)

        @other_user_receipt = Factory(:gift_receipt, :facebook_id => 111222333)
      end

      it 'should give items to character' do
        lambda {
          @character.gifts.accept!(:all)
        }.should change(@character.inventories, :count).from(0).to(2)
      end

      it 'should accept all gifts fot the character' do
        @character.gifts.accept!(:all)

        @gift_receipt.reload.accepted.should be_true
        @other_receipt.reload.accepted.should be_true
        
        @other_user_receipt.reload.accepted.should be_false
      end

      it 'should return an array of accepted gifts' do
        @character.gifts.accept!(:all).should include(@gift, @other_gift)
      end

      it 'should assign inventories to all gifts' do
        gifts = @character.gifts.accept!(:all)

        gifts.collect(&:inventory).size.should == 2
        gifts.collect(&:inventory).should include(*@character.inventories.all)
      end

      it 'should work with string \'all\' as well' do
        @character.gifts.accept!('all').should_not be_empty
      end
    end
  end
end