require "spec_helper"

describe User do
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
end