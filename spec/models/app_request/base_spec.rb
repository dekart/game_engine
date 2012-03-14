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
  
  describe 'states' do
    before do
      @request = Factory(:app_request_base)
    end
    
    describe 'when pending' do
      before do
        @request.update_attribute(:state, 'pending')
      end
      
      it 'should be processable' do
        @request.can_process?.should be_true
      end
      
      it 'should be markable as broken' do
        @request.can_mark_broken?.should be_true
      end
      
      it 'should be visitable' do
        @request.can_visit?.should be_true
      end

      it 'should be ignorable' do
        @request.can_ignore?.should be_true
      end

      it 'should not be acceptable' do
        @request.can_accept?.should_not be_true
      end
    end
    
    describe 'when processed' do
      it 'should be acceptable' do
        @request.can_accept?.should be_true
      end
      
      it 'should be ignorable' do
        @request.can_ignore?.should be_true
      end

      it 'should be visitable' do
        @request.can_visit?.should be_true
      end
    end
    
    describe 'when visited' do
      before do
        @request.update_attribute(:state, 'visited')
      end
      
      it 'should be acceptable' do
        @request.can_accept?.should be_true
      end
      
      it 'should be ignorable' do
        @request.can_ignore?.should be_true
      end
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
  
  
  describe '.check_user_requests' do
    before do
      @facebook_requests = [
        {'id' => '123_111'},
        {'id' => '456_222'}
      ]
      @koala = mock('koala', :get_connections => @facebook_requests)
      @user = mock_model(User, :facebook_id => 123456789, :facebook_client => @koala)
      
      @request1 = mock_model(AppRequest::Base, :update_from_facebook_request => true, :pending? => true)
      @request2 = mock_model(AppRequest::Base, :update_from_facebook_request => true, :pending? => false)
      
      AppRequest::Base.stub!(:find_or_initialize_by_facebook_id_and_receiver_id).and_return(@request1, @request2)
    end
    
    it 'should fetch app request data from facebook' do
      @koala.should_receive(:get_connections).with('me', 'apprequests').and_return(@facebook_requests)
      
      AppRequest::Base.check_user_requests(@user)
    end
    
    it 'should find or initialize new request for each facebook request' do
      AppRequest::Base.should_receive(:find_or_initialize_by_facebook_id_and_receiver_id).twice.and_return(@request1, @request2)
      
      AppRequest::Base.check_user_requests(@user)
    end
    
    it 'should update data for each pending request' do
      @request1.should_receive(:update_from_facebook_request)
      
      AppRequest::Base.check_user_requests(@user)
    end
    
    it 'should not update requests if they\'re not pending' do
      @request2.should_not_receive(:update_from_facebook_request)
      
      AppRequest::Base.check_user_requests(@user)
    end
  end
  
  
  describe '.schedule_deletion' do
    before do
      @request1 = Factory(:app_request_base)
      @request2 = Factory(:app_request_gift)
    end
    
    it 'should schedule deletion for passed request IDs' do
      lambda{
        AppRequest::Base.schedule_deletion(@request1.id, @request2.id)
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request1.id, @request2.id]
    end
    
    it 'should correctly accept array of requests' do
      lambda{
        AppRequest::Base.schedule_deletion(@request1, @request2)
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request1.id, @request2.id]
    end
    
    it 'should ignore nil values in passed params' do
      lambda{
        AppRequest::Base.schedule_deletion(@request1, nil)
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request1.id]
    end
    
    it 'should not schedule any jobs if result ID array is empty' do
      lambda{
        AppRequest::Base.schedule_deletion(nil)
      }.should_not change(Delayed::Job, :count)
    end
    
    it 'should accept nested arrays' do
      lambda{
        AppRequest::Base.schedule_deletion([@request1], @request2)
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request1.id, @request2.id]
    end
    
    it 'should now repeatedly schedule deletion if requests do repeat' do
      lambda{
        AppRequest::Base.schedule_deletion([@request1, @request2], @request1, @request1.id, @request2, @request2.id)
      }.should change(Delayed::Job, :count).by(1)
      
      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request1.id, @request2.id]
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
  
  
  describe '#update_from_facebook_request' do
    before do
      @sender   = Factory(:user_with_character, :facebook_id => 123)
      @receiver = Factory(:user_with_character, :facebook_id => 456)
      
      @request = Factory(:app_request_base, :state => 'pending')
      
      @remote_request = {
        'from' => { 'id' => 123 },
        'to'   => { 'id' => 456 },
        'data' => '{"type":"invite"}',
        'created_time' => '2011-11-05T08:31:08+0000'
      }
    end
    
    it 'should assign sender' do
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :sender).from(nil).to(@sender.character)
    end
    
    it 'should assign receiver ID' do
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :receiver_id).from(123456789).to(456)
    end
    
    it 'should parse and assign request data' do
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :data).from(nil).to('type' => 'invite')
    end
    
    it 'should not try to parse empty request data' do
      @remote_request['data'] = nil
      
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should_not change(@request, :data)
    end
    
    it 'should save request' do
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :data)
    end
    
    it 'should mark request as processed' do
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :processed?).from(false).to(true)
    end
    
    it 'should ignore request if remote request sender is not defined' do
      @remote_request['from'] = nil
      
      lambda{
        @request.update_from_facebook_request(@remote_request)
      }.should change(@request, :ignored?).from(false).to(true)
    end
    
    describe 'when request type is set' do
      it 'should change request class to gift if request is a gift request' do
        @remote_request['data'] = '{"type":"gift"}'

        @request.update_from_facebook_request(@remote_request)

        AppRequest::Base.find(@request.id).should be_kind_of(AppRequest::Gift)
      end

      it 'should change request class to invitation if request is a invitation request' do
        @remote_request['data'] = '{"type":"invitation"}'

        @request.update_from_facebook_request(@remote_request)

        AppRequest::Base.find(@request.id).should be_kind_of(AppRequest::Invitation)
      end

      it 'should change request class to monster invite if request is a monster invite request' do
        @monster = Factory(:monster)
        
        @remote_request['data'] = '{"type":"monster_invite","monster_id":%d}' % @monster.id

        @request.update_from_facebook_request(@remote_request)

        AppRequest::Base.find(@request.id).should be_kind_of(AppRequest::MonsterInvite)
      end
      
      it 'should not fail if request type is set incorrectly' do
        @remote_request['data'] = '{"type":"monster"}'

        lambda {
          @request.update_from_facebook_request(@remote_request)
        }.should_not raise_exception
      end
      
      it 'should be incorrect after processing' do
        #  TODO: hack. it doesnt work without it, because after update_from_facebook_request object becomes another object
        @request.stub!(:becomes).and_return(@request)
        @request.stub!(:correct?).and_return(false)
        
        lambda {
          @request.update_from_facebook_request(@remote_request)
        }.should change(@request, :state).from('pending').to('incorrect')
      end
    end
    
    describe 'when type is not set' do

      it 'should change request class to invitation if data is not set' do
        @remote_request['data'] = nil

        @request.update_from_facebook_request(@remote_request)

        AppRequest::Base.find(@request.id).should be_kind_of(AppRequest::Invitation)
      end

      it 'should change request class to invitation if data is set but without type' do
        @remote_request['data'] = '{"something":"else"}'

        @request.update_from_facebook_request(@remote_request)

        AppRequest::Base.find(@request.id).should be_kind_of(AppRequest::Invitation)
      end

    end
  end
  
  
  describe '#check_request' do
    before do
      @request = Factory(:app_request_invitation, :state => 'pending')
      @request.stub!(:update_from_facebook_request).and_return(true)

      @remote_request = mock('remote_request')

      @koala = mock('koala', :get_object => @remote_request)

      Facepalm::Config.default.stub(:api_client).and_return(@koala)
    end
    
    after do
      Facepalm::Config.send(:remove_class_variable, :@@default)
    end

    it 'should find or initialize new request for facebook request' do
      @koala.should_receive(:get_object).with("123456789_123456789").and_return(@remote_request)

      @remote_request.should_receive(:[]).with("data").twice.and_return(@remote_request['data'])

      @remote_request.should_receive(:[]).with("id").and_return("123456789_123456789")

      AppRequest::Base.should_receive(:find_or_initialize_by_facebook_id_and_receiver_id).and_return(@request)

      AppRequest::Base.check_request(123456789, ["123456789"])
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
      
      @koala = mock('koala', :delete_object => true)
      Facepalm::Config.default.stub!(:api_client).and_return(@koala)
    end
    
    after do
      Facepalm::Config.send(:remove_class_variable, :@@default)
    end
    
    it 'should delete request from facebook using application access token' do
      @koala.should_receive(:delete_object).with("123456789_123456789")
      
      @request.delete_from_facebook!
    end
  end


  describe '#process' do
    before do
      @sender = Factory(:character)
      @request = Factory(:app_request_base, :state => 'pending', :sender => @sender, :sent_at => Time.now)
    end
    
    it 'should store processing time' do
      Timecop.freeze(Time.now) do
        lambda{
          @request.process
          @request.reload
        }.should change(@request, :processed_at).from(nil).to(Time.at(Time.now.to_i))
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
          @request.reload
        }.should change(@request, :visited_at).from(nil).to(Time.at(Time.now.to_i))
      end
    end
  end


  describe "#accept" do
    before do
      @request = Factory(:app_request_base)
    end
  
    it_should_behave_like 'application request accept'
  end


  describe '#ignore' do
    before do
      @request = Factory(:app_request_base)
    end
    
    it 'should schedule request deletion' do
      lambda{
        @request.ignore
      }.should change(Delayed::Job, :count).by(1)

      Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
      Delayed::Job.last.payload_object.request_ids.should == [@request.id]
    end
  end
end