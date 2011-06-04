require 'spec_helper'

class FakeCanvasOAuthController < ActionController::Base
  include Facebooker2::Rails::Controller

  before_filter :check_connection_and_permissions
  
  def callback_url
    "my url"
  end
  
  def check_connection_and_permissions
    ensure_canvas_connected(:permission, :other)
  end
end

describe Facebooker2::Rails::Controller::CanvasOAuth do
  before(:each) do
    Facebooker2.canvas_page_name = 'my-application'
    Facebooker2.app_id = '12345'
  end

  let :controller do
    FakeCanvasOAuthController.new.tap do |controller|
      controller.stub!(:request).and_return(mock('request', :protocol => 'http://'))
    end
  end

  describe "should extend with OAuth class methods" do
    [ :ensure_canvas_connected, :facebook_oauth_connect ].each do |method|
      it "#{method}" do
        controller.respond_to?(method).should be_true
      end
    end
  end

  describe "Canvas OAuth connections" do
    it "should fail if no canvas page is defined" do
      Facebooker2.canvas_page_name = nil

      lambda { controller.send(:facebook_oauth_connect) }.should raise_error
    end

    it "should throw an OAuth exception if there was an error in authenticating" do
      controller.stub!(:params).and_return(:error => { :message => 'User denied access.' })

      lambda { controller.send(:facebook_oauth_connect) }.should raise_error(Facebooker2::OAuthException, 'User denied access.')
    end

    it "should throw an OAuth exception if no code is returned" do
      controller.stub!(:params).and_return({})

      lambda { controller.send(:facebook_oauth_connect) }.should raise_error(Facebooker2::OAuthException, 'No code returned.')
    end

    it "should redirect to the canvas application on success" do
      controller.stub!(:params).and_return(:code => '12345')
      controller.should_receive(:redirect_to).with('http://apps.facebook.com/my-application')
      controller.send(:facebook_oauth_connect)
    end
  end

end
