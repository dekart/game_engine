require 'spec_helper'

describe AppRequest do
  describe 'associations' do
    before do
      @request = AppRequest.new
    end
    
    it 'should belong to sender' do
      @request.should belong_to(:sender)
    end
  end
  
  describe 'when creating' do
    before do
      @request = AppRequest.new(:facebook_id => 123)
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
      
      @request = Factory(:app_request)
      
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
      }.should change(@request, :sender).from(nil).to(@sender)
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
    
    it 'should save request' do
      @request.update_data!
      
      @request.should_not be_changed
    end
    
    it 'should mark request as processed' do
      lambda{
        @request.update_data!
      }.should change(@request, :processed?).from(false).to(true)
    end
    
    describe 'when request is an invitation request' do
      before do
        @remote_request.stub!(:data).and_return('{"type":"invitation"}')
      end
      
      it 'should create an invitation from sender to receiver' do
        lambda{
          @request.update_data!
        }.should change(Invitation, :count).by(1)
        
        Invitation.last.sender.should == @sender
        Invitation.last.receiver_id.should == 456
      end
    end
    
    describe 'when request is a gift' do
      before do
        @item = Factory(:item)
        @remote_request.stub!(:data).and_return('{"type":"gift","item_id":"%d"}' % @item.id)
      end
      
      it 'should create a gift from sender to receiver' do
        lambda{
          @request.update_data!
        }.should change(Gift, :count).by(1)
        
        Gift.last.sender.should == @sender.character
        Gift.last.receiver_id.should == 456
        Gift.last.item.should == @item
      end
    end
  end
  
  describe '#reference' do
    before do
      @request = Factory(:app_request, :data => {"reference" => 'some_reference'})
    end
    
    it 'should return reference value from data' do
      @request.reference.should == 'some_reference'
    end
    
    it 'should return empty string when data is not set' do
      @request.data = nil
      
      @request.reference.should == ''
    end
  end
  
  describe '#delete_from_facebook!' do
    before do
      @request = Factory(:app_request)
      
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
  
  describe '#return_to' do
    before do
      @request = Factory(:app_request, :data => {'return_to' => '/some/url'})
    end
    
    it 'should return stored value from data' do
      @request.return_to.should == '/some/url'
    end
      
    it 'should return nil if data is not set' do
      @request.data = nil
      
      @request.return_to.should be_nil
    end
    
    it 'should return nil if data is set, but return url is not set' do
      @request.data = {:something => 'else'}
      
      @request.return_to.should be_nil
    end
  end
  
  describe '#process' do
    before do
      @request = Factory(:app_request)
    end
    
    it 'should store processing time' do
      Timecop.freeze(Time.now) do
        lambda{
          @request.process
        }.should change(@request, :processed_at).from(nil).to(Time.now)
      end
    end
  end
  
  %w{accept accept_indirectly}.each do |method_name|
    describe "##{method_name}" do
      before do
        @request = Factory(:app_request)
      end
    
      it 'should store acceptance time' do
        Timecop.freeze(Time.now) do
          lambda{
            @request.send(method_name)
          }.should change(@request, :accepted_at).from(nil).to(Time.now)
        end
      end
    
      it 'should schedule request deletion' do
        lambda{
          @request.send(method_name)
        }.should change(Delayed::Job, :count).by(1)
      
        Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
        Delayed::Job.last.payload_object.request_ids.should == [@request.id]
      end
    end
  end
end