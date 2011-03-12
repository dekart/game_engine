require 'spec_helper'
require 'models/app_request/common'

describe AppRequest::Base do
  describe 'associations' do
    before do
      @request = AppRequest::Base.new
    end
    
    it 'should belong to sender' do
      @request.should belong_to(:sender)
    end
  end
  
  describe '.for_character' do
    before do
      @receiver = Factory(:user_with_character).character
      
      @request1 = Factory(:app_request_base, :receiver_id => 123456789)
      @request2 = Factory(:app_request_base, :receiver_id => 123456789)
      @request3 = Factory(:app_request_base, :receiver_id => 111222333)
    end
    
    it 'should return gifts sent to passed character' do
      AppRequest::Base.for_character(@receiver).should include(@request1, @request2)
      AppRequest::Base.for_character(@receiver).should_not include(@request3)
    end
  end

  describe 'when creating' do
    before do
      @request = AppRequest::Base.new(:facebook_id => 123)
    end
    
    it 'should validate presence of facebook ID' do
      @request.should validate_presence_of(:facebook_id)
    end
    
    it 'should successfully save' do
      @request.save.should be_true
    end
    
    it 'should schedule data update' do
      lambda{
        @request.save
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDataUpdate)
    end
  end
  
  describe 'when updating data' do
    before do
      @sender = Factory(:user_with_character, :facebook_id => 123)
      
      @request = Factory(:app_request_base)
      
      @client = mock('mogli client')
      
      Mogli::AppClient.stub!(:create_and_authenticate_as_application).and_return(@client)

      @remote_request = mock('request on facebook',
        :from => mock('sender', :id => 123),
        :to => mock('receiver', :id => 456),
        :data => '{"abc":"dfg"}'
      )
      
      Mogli::AppRequest.stub!(:find).and_return(@remote_request)
    end
    
    it 'should fetch data from API using application token' do
      Mogli::AppRequest.should_receive(:find).with(123456789, @client).and_return(@remote_request)
      
      @request.update_data!
    end
    
    it 'should assign sender' do
      lambda{
        @request.update_data!
      }.should change(@request, :sender).from(nil).to(@sender.character)
    end
    
    it 'should assign receiver ID' do
      lambda{
        @request.update_data!
      }.should change(@request, :receiver_id).from(nil).to(456)
    end
    
    it 'should parse and assign request data' do
      lambda{
        @request.update_data!
      }.should change(@request, :data).from(nil).to('abc' => 'dfg')
    end
    
    it 'should not try to parse empty request data' do
      @remote_request.should_receive(:data).and_return(nil)
      
      lambda{
        @request.update_data!
      }.should_not change(@request, :data)
    end
    
    it 'should save request' do
      @request.update_data!
      
      @request.should_not be_changed
    end
    
    it 'should mark request as processed' do
      lambda{
        @request.update_data!
      }.should change(@request, :processed?).from(false).to(true)
    end
  end
  
  
  describe '#receiver' do
    before do
      @receiver = Factory(:user_with_character).character
      @request = Factory(:app_request_base, :receiver_id => 123456789)
    end
    
    it 'should return character for user with facebook UID equal to stored receiver ID' do
      @request.receiver.should == @receiver
    end
    
    it 'should return nil if there is no character for such UID' do
      @request = Factory(:app_request_base, :receiver_id => 111222333)
      
      @request.receiver.should be_nil
    end
    
    it 'should memoize receiver' do
      @request.receiver
      
      User.should_not_receive(:find_by_facebook_id)
      
      @request.receiver
    end
  end
  
  
  describe '#acceptable?' do
    it 'should always return true' do
      Factory(:app_request_base).acceptable?.should be_true
    end
  end


  describe '#delete_from_facebook!' do
    before do
      @request = Factory(:app_request_base)
      
      @client = mock('mogli client')
      
      Mogli::AppClient.stub!(:create_and_authenticate_as_application).and_return(@client)
      
      @remote_request = mock('request on facebook', :destroy => true)
      
      Mogli::AppRequest.stub!(:new).and_return(@remote_request)
    end
    
    it 'should delete request from facebook using application access token' do
      Mogli::AppRequest.should_receive(:new).with({:id => 123456789}, @client).and_return(@remote_request)
      
      @remote_request.should_receive(:destroy)
      
      @request.delete_from_facebook!
    end
  end
  
  describe '#process' do
    before do
      @request = Factory(:app_request_base)
    end
    
    it 'should store processing time' do
      Timecop.freeze(Time.now) do
        lambda{
          @request.process
        }.should change(@request, :processed_at).from(nil).to(Time.now)
      end
    end
  end

  describe '#visit' do
    before do
      @request = Factory(:app_request_base)
    end
    
    it 'should store visit time' do
      Timecop.freeze(Time.now) do
        lambda{
          @request.visit
        }.should change(@request, :visited_at).from(nil).to(Time.now)
      end
    end
  end
  
  describe "#accept" do
    before do
      @request = Factory(:app_request_base)
    end
  
    it_should_behave_like 'application request accept'
  end
end