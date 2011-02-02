require 'spec_helper'

describe AppRequestsController do
  describe "when routing" do
    it "should map POST /app_requests to the request creation action" do
      params_from(:post, "/app_requests").should == {
        :controller   => "app_requests",
        :action       => "create"
      }
    end
  end
  
  describe 'when creating requests' do
    before do
      AppRequest.stub!(:create).and_return(true)
    end
    
    def do_request
      post :create, :request_ids => [123]
    end
    
    it 'should create new application request for each passed request ID' do
      AppRequest.should_receive(:create).with(:facebook_id => 123)
      
      do_request
    end
    
    it 'should render empty page' do
      do_request
      
      response.body.should be_blank
    end
  end
end