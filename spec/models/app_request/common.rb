shared_examples_for 'application request accept' do
  it 'should store acceptance time' do
    Timecop.freeze(Time.now) do
      lambda{
        @request.accept
      }.should change(@request, :accepted_at).from(nil).to(Time.now)
    end
  end

  it 'should schedule request deletion' do
    lambda{
      @request.accept
    }.should change(Delayed::Job, :count).by(1)
  
    Delayed::Job.last.payload_object.should be_kind_of(Jobs::RequestDelete)
    Delayed::Job.last.payload_object.request_ids.should == [@request.id]
  end
end