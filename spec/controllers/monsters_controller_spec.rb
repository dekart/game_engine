require 'spec_helper'

describe MonstersController do
  include FacebookSpecHelper

  before do
    controller.stub!(:current_facebook_user).and_return(fake_fb_user)
  end

  describe "when routing" do
    it "should map GET /monsters to a monster list" do
      params_from(:get, "/monsters").should == {
        :controller   => "monsters",
        :action       => "index"
      }
    end

    it "should map POST /monsters to a monster creation" do
      params_from(:post, "/monsters").should == {
        :controller   => "monsters",
        :action       => "create"
      }
    end

    it "should map GET /monsters/123 to a monster fight information page" do
      params_from(:get, "/monsters/123").should == {
        :controller   => "monsters",
        :action       => "show",
        :id           => "123"
      }
    end

    it "should map PUT /monsters/123 to a monster fight action" do
      params_from(:put, "/monsters/123").should == {
        :controller   => "monsters",
        :action       => "update",
        :id           => "123"
      }
    end
  end

  describe "when displaying monster list" do
    def do_request
      get :index
    end

    before do
      @available_types = mock("available monster types")
      @monster_types = mock("character monster types", :available => @available_types)
      @character = mock_model(Character, :monster_types => @monster_types)

      controller.stub!(:current_character).and_return(@character)
    end

    it "should fetch a list of available monster types" do
      @monster_types.should_receive(:available).and_return(@available_types)

      do_request
    end

    it "should pass monster type list to the template" do
      do_request

      assigns[:monster_types].should == @available_types
    end

    it "should fetch a list of recently active monster fights"
    it "should pass monster fight list to the template"

    it "should render 'index'" do
      do_request

      response.should render_template(:index)
    end
  end

  describe "when starting monster fight" do
    def do_request
      post :create, :monster_type_id => 123
    end

    it "should fetch monster type"
    it "should initialize new monster of the defined type"
    it "should try to save the monster"

    describe "if monster was saved successfully" do
      it "should redirect to the monster fight information page"
    end

    describe "if monster failed to save" do
      it "should display error message"
      it "should redirect to monster index page"
    end
  end
end