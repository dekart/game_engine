require 'spec_helper'

describe Gift do
  context 'associations' do
    before do
      @gift = Gift.new
    end
    
    it 'should belong to sender' do
      @gift.should belong_to(:sender)
    end
    
    it 'should belong to item' do
      @gift.should belong_to(:item)
    end
    
    it 'should belong to application request' do
      @gift.should belong_to(:app_request)
    end
  end
  
  describe '.for_character' do
    before do
      @receiver = Factory(:character)
      
      @gift1 = Factory(:gift)
      @gift2 = Factory(:gift)
      @gift3 = Factory(:gift, :receiver_id => 987654321)
    end
    
    it 'should return gifts sent to passed character' do
      Gift.for_character(@receiver).should include(@gift1, @gift2)
      Gift.for_character(@receiver).should_not include(@gift3)
    end
  end
  
  describe '.accepted_recently' do
    before do
      @gift1 = Factory(:gift)
      @gift2 = Factory(:gift)
      
      @gift1.accept!
      @gift2.accept!
      
      @gift3 = Factory(:gift)
      
      Timecop.travel((24.hours + 1.minute).ago) do
        @gift3.accept!
      end
      
      @gift4 = Factory(:gift)
    end
    
    it 'should return gifts accepted less than 24 hours ago' do
      @gift1.should be_accepted
      @gift2.should be_accepted

      Gift.accepted_recently.should include(@gift1, @gift2)
    end
    
    it 'should not return gifts accepted more than 24 hours ago' do
      @gift3.should be_accepted
      
      Gift.accepted_recently.should_not include(@gift3)
    end
    
    it 'should not return unaccepted gifts' do
      Gift.accepted_recently.should_not include(@gift4)
    end
  end
  
  describe '#receiver' do
    before do
      @receiver = Factory(:character)
      @gift = Factory(:gift)
    end
    
    it 'should return user with facebook UID equal to stored receiver ID' do
      @gift.receiver.should == @receiver
    end
  end
  
  describe '#accept' do
    before do
      @item     = Factory(:item)
      @receiver = Factory(:character)
      @gift     = Factory(:gift)
    end
    
    it 'should fail if receiver already accepted a gift from the same sender recently' do
      @other_gift = Factory(:gift, :sender => @gift.sender, :receiver_id => @gift.receiver_id)
      @other_gift.accept
      
      @gift.accept.should be_false
    end
    
    it 'should change state of the gift to \'accepted\'' do
      lambda{
        @gift.accept
      }.should change(@gift, :accepted?).from(false).to(true)
    end
    
    it 'should set and store acceptance time' do
      @gift.accept
      
      @gift.reload.accepted_at.should_not be_nil
    end
    
    it 'should give item to receiver' do
      lambda{
        @gift.accept
      }.should change(@receiver.inventories, :count).from(0).to(1)
      
      @gift.inventory.should == @receiver.inventories.first
    end
    
    it 'should schedule application request deletion' do
      lambda{
        @gift.accept
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == @gift.app_request_id
    end
  end
end