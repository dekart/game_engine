require 'spec_helper'

describe ApplicationController do
  describe 'when fetching current user' do
    before do
      controller.stub!(:current_facebook_user).and_return(fake_fb_user)
      
      @user = Factory(:user, :facebook_id => 123456789)
    end
    
    describe 'when there is no user with such facebook UID' do
      before do
        @user.update_attribute(:facebook_id, 987654321)
      end
      
      it 'should create user for this UID'
      
      it 'should assign user signup IP'
      
      describe 'if reference code are passed' do
        it 'should assign user reference'
        it 'should assign user referrer'
        it 'should not assign reference or referrer if reference code is invalid'
      end
      
      describe 'if request IDs are passed' do
        before do
          controller.params[:request_ids] = '123,456'
          
          @sender = Factory(:user, :facebook_id => 111222333)
          
          @request = Factory(:app_request, 
            :facebook_id => 123, 
            :sender => @sender,
            :data => {'reference' => 'some_reference'}
          )
        end
        
        it 'should assign user reference from request data' do
          controller.send(:current_user).reference.should == 'some_reference'
        end
        
        it 'should assign user referrer from request sender' do
          controller.send(:current_user).referrer.should == @sender
        end
        
        it 'should not assign reference or referrer is request ID is wrong' do
          controller.params[:request_ids] = 987
          
          user = controller.send(:current_user)
          
          user.reference.should be_empty
          user.referrer.should be_nil
        end
        
        it 'should not assign reference request data is empty' do
          @request.update_attribute(:data, nil)
          
          controller.send(:current_user).reference.should be_empty
        end
        
        it 'should not assign refererr request sender is not set' do
          @request.update_attribute(:sender, nil)
          
          controller.send(:current_user).referrer.should be_nil
        end
      end
    end
    
    it 'should store current access token for the user'
    it 'should store token expiration date for the user'
    it 'should update last visit time for the user'
    it 'shouldn\'t update last visit time if user visited the app less than 30 minutes ago'
    it 'should update last visit IP for the user'
    
    it 'should return saved user' do
      controller.send(:current_user).should == @user
      
      @user.should_not be_new_record
      @user.should_not be_changed
    end
    
    it 'should return nil when not authenticated as Facebook user'
  end
end