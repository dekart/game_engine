require 'spec_helper'

describe Jobs::RequestDataUpdate do
  describe 'when performing' do
    before do
      @job = Jobs::RequestDataUpdate.new(123)
      
      @request = mock_model(AppRequest::Base, :update_data! => true)
      
      AppRequest::Base.stub!(:find_by_id).and_return(@request)
    end
    
    it 'should fetch request by passed ID' do
      AppRequest::Base.should_receive(:find_by_id).with(123).and_return(@request)
      
      @job.perform
    end
    
    it 'should update data for the request' do
      @request.should_receive(:update_data!).and_return(true)
      
      @job.perform
    end
  end
end