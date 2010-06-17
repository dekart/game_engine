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
end