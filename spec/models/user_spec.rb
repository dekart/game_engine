require "spec_helper"

describe User do
  describe 'when creating' do
    before do
      @user = Factory.build(:user)
    end
    
    it 'should schedule user data update' do
      lambda{
        @user.save!
      }.should change(Delayed::Job, :count).from(0).to(1)
      
      Delayed::Job.first.payload_object.should be_kind_of(Jobs::UserDataUpdate)
      Delayed::Job.first.payload_object.user_ids.should == [@user.id]
    end
  end
  
  
  describe "when checking if user should visit landing page" do
    before :each do
      @user = Factory(:user)
    end

    it "should delay first visit for 24 hours" do
      @user.created_at = (24.hours - 1.minute).ago

      @user.should_visit_landing_page?.should be_false

      @user.created_at = (24.hours + 1.minute).ago
      
      @user.should_visit_landing_page?.should be_true
    end

    it "should delay visit for 24 hours" do
      @user.created_at = 1.month.ago

      @user.landing_visited_at = (24.hours - 1.minute).ago

      @user.should_visit_landing_page?.should be_false

      @user.landing_visited_at = (24.hours + 1.minute).ago

      @user.should_visit_landing_page?.should be_true
    end
  end

  describe "when updating visiting landing page" do
    before :each do
      @user = Factory(:user)
    end
    
    it "should change last visited landing" do
      lambda{
        @user.visit_landing!(:some_page)
      }.should change(@user, :last_landing).to("some_page")
    end

    it "should change landing timestamp" do
      time = Time.now.utc

      Time.stub!(:now).and_return(time)

      lambda{
        @user.visit_landing!(:some_page)
      }.should change(@user, :landing_visited_at).to(time)
    end

    it "should save the user" do
      @user.visit_landing!(:some_page)

      @user.should_not be_changed
    end
  end

  describe "when assigning signup IP" do
    before do
      @user = User.new
    end
    
    it 'should covert string value to integer' do
      lambda{
        @user.signup_ip = '127.0.0.1'
      }.should change(@user, :signup_ip).from(nil).to(2130706433)
    end
    
    it 'should store integer value as is' do
      lambda{
        @user.signup_ip = 64000
      }.should change(@user, :signup_ip).from(nil).to(64000)
    end
  end
  
  describe "when retrieving signup IP" do
    before do
      @user = User.new
      @user.signup_ip = '127.0.0.1'
    end
    
    it 'should return parsed IP value as IPAddr object' do
      @user.signup_ip.should be_kind_of(IPAddr)
      @user.signup_ip.should == IPAddr.new('127.0.0.1')
    end
    
    it 'should return nil if IP is not set' do
      @user.signup_ip = nil
      
      @user.signup_ip.should be_nil
    end
    
    it 'should correctly store values after 127.*' do
      @user.signup_ip = '250.250.250.250'
      @user.save!
      
      @user.reload.signup_ip.should == IPAddr.new('250.250.250.250')
    end
  end
  
  describe "when assigning last visit IP" do
    before do
      @user = User.new
    end
    
    it 'should covert string value to integer' do
      lambda{
        @user.last_visit_ip = '127.0.0.1'
      }.should change(@user, :last_visit_ip).from(nil).to(2130706433)
    end
    
    it 'should store integer value as is' do
      lambda{
        @user.last_visit_ip = 64000
      }.should change(@user, :last_visit_ip).from(nil).to(64000)
    end
  end

  describe "when retrieving last visit IP" do
    before do
      @user = User.new
      @user.last_visit_ip = '127.0.0.1'
    end
    
    it 'should return parsed IP value as IPAddr object' do
      @user.last_visit_ip.should be_kind_of(IPAddr)
      @user.last_visit_ip.should == IPAddr.new('127.0.0.1')
    end
    
    it 'should return nil if IP is not set' do
      @user.last_visit_ip = nil
      
      @user.last_visit_ip.should be_nil
    end
    
    it 'should correctly store values after 127.*' do
      @user.last_visit_ip = '250.250.250.250'
      @user.save!
      
      @user.reload.last_visit_ip.should == IPAddr.new('250.250.250.250')
    end
  end
  
  describe 'when updating social data' do
    before do
      @user = Factory(:user)
      
      @mogli_user = mock('Mogli::User',
        :client= => true,
        :fetch => true,
        
        :first_name => 'Fake Name',
        :last_name => 'Fake Surname',
        :timezone => 5,
        :locale => 'ab_CD',
        :gender => 'male',
        
        :third_party_id => 'abcd1234'
      )
      
      Mogli::User.stub!(:find).and_return(@mogli_user)
    end
    
    it 'should successfully update data' do
      @user.update_social_data!.should be_true
    end
    
    it 'should return false if user doesn\'t have access token' do
      @user.access_token = ''
      
      @user.update_social_data!.should be_false
    end
    
    it 'should return false if access token is already expired' do
      @user.access_token_expire_at = 1.minute.ago
      
      @user.update_social_data!.should be_false
    end
    
    it 'should fetch user data using Facebook API' do
      Mogli::User.should_receive(:find).and_return(@mogli_user)
      
      @user.update_social_data!
    end
    
    it "should update first name to received value" do
      lambda{
        @user.update_social_data!
      }.should change(@user, :first_name).from('').to('Fake Name')
    end

    it "should update last name to received value" do
      lambda{
        @user.update_social_data!
      }.should change(@user, :last_name).from('').to('Fake Surname')
    end
    
    it "should update time zone to received value" do
      lambda{
        @user.update_social_data!
      }.should change(@user, :timezone).from(nil).to(5)
    end

    it "should update locale to received value" do
      lambda{
        @user.update_social_data!
      }.should change(@user, :locale).from('en_US').to('ab_CD')
    end

    it 'should update gender to received value' do
      lambda{
        @user.update_social_data!
      }.should change(@user, :gender).from(nil).to(1)
    end
    
    it 'should not try to update gender is there is no gender in received data' do
      @mogli_user.should_receive(:gender).and_return(nil)
      
      lambda{
        @user.update_social_data!
      }.should_not change(@user, :gender)
    end
    
    it "should update third-party id to received value" do
      lambda{
        @user.update_social_data!
      }.should change(@user, :third_party_id).from('').to('abcd1234')
    end

    it 'should save user' do
      @user.update_social_data!
      
      @user.should_not be_changed
    end
  end
end