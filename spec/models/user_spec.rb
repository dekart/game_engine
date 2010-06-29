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

  describe "permissions" do
    before :each do
      @user = Factory(:user)
    end

    it "should include email permission" do
      User::PERMISSIONS.should include("email")
    end

    describe "when clearing" do
      before :each do
        @user.permission_email = true
      end

      it "should clear email permission" do
        lambda{
          @user.clear_permissions
        }.should change(@user, :permission_email).from(true).to(false)
      end
    end

    describe "when adding new permissions" do
      it "should add email permissions" do
        lambda{
          @user.add_permissions("email")
        }.should change(@user, :permission_email).from(false).to(true)
      end

      it "should not change permissions that weren't passed" do
        lambda{
          @user.add_permissions(nil)
        }.should_not change(@user, :permission_email)
      end

      it "should'n fail when passed unsupported permission" do
        lambda{
          @user.add_permissions("non_existent_permission")
        }.should_not raise_exception
      end
    end

    describe "when updating" do
      it "should clear all permissions when empty value is passed" do
        @user.update_permissions!(nil)

        @user.permission_email.should be_false
      end

      it "should add all passed permissions" do
        @user.update_permissions!("email")

        @user.permission_email.should be_true
      end

      it "should save user" do
        @user.update_permissions!("email")

        @user.should_not be_changed
      end
    end

    describe "when checking if should check permissions" do
      it "should return false if delay is set to 0" do
        Setting.should_receive(:i).with(:user_permission_request_delay).and_return(0)

        @user.should_request_permissions?.should be_false
      end

      it "should return false if user were created less than 24 hours ago" do
        @user.created_at = (24.hours - 1.second).ago

        @user.should_request_permissions?.should be_false
      end

      describe "when user were created more than 24 hours ago" do
        before :each do
          @user.created_at = (24.hours + 1.second).ago
        end

        it "should return false if permissions were asked less than 24 hours ago" do
          @user.permissions_requested_at = (24.hours - 1.second).ago

          @user.should_request_permissions?.should be_false
        end

        it "should return true if permissions weren't asked at all" do
          @user.should_request_permissions?.should be_true
        end

        it "should return true if permissions were asked more than 24 hours ago" do
          @user.permissions_requested_at = (24.hours + 1.second).ago

          @user.should_request_permissions?.should be_true
        end
      end

    end
  end
end