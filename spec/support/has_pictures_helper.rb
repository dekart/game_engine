describe Picture do
  shared_examples_for 'should have pictures' do
    def prepare_picture_container
      @container = Factory(described_class.to_s.underscore.to_sym)

      @container.picture_attributes = []
    end

    it 'should have many pictures' do
      prepare_picture_container

      @container.should respond_to(:pictures)
    end

    it 'pictures should return url for given picture style' do
      prepare_picture_container

      @container.pictures.url.should be_instance_of(String)
    end
  end
end