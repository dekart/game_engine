describe Picture do
  shared_examples_for 'should have pictures' do
    before(:each) do
      @container = Factory(described_class.to_s.underscore.to_sym)
      
      @container.picture_attributes = []
    end
    
    it 'should have many pictures' do
      @container.should respond_to(:pictures)
    end
    
    it 'pictures should return url for given picture style' do
      @container.pictures.url.should be_instance_of(String)
    end
  end
end