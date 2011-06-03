require 'spec_helper'

describe FightsController do
  before do
    controller.stub!(:current_facebook_user).and_return(fake_fb_user)
  end
  
  describe 'index' do
    it "should succesfully render" do
      get :index

      response.should be_success
    end
  end  
end