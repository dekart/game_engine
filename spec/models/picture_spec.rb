require File.expand_path("../../spec_helper", __FILE__)

describe Picture do
  before(:each) do
    @picture = Picture.new(:style => "original", :image => File.open('public/images/1px.gif'))
  end
  
  it 'should have attachment' do
    @picture.should have_attached_file(:image)
    
    @picture.image.should be_kind_of(Paperclip::Attachment)
  end
end