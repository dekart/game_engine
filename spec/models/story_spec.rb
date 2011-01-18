require 'spec_helper'

describe Story do
  describe 'defaults' do
    it 'should be hidden by default' do
      Story.new.should be_hidden
    end
    
    it 'should have attachment' do
      Story.new.should have_attached_file(:image)
    end
  end
  
  describe 'when creating' do
    before do
      @story = Factory.build(:story)
    end
    
    it 'should be invalid without alias' do
      @story.should validate_presence_of(:alias)
    end
    
    it 'should be invalid without title' do
      @story.should validate_presence_of(:title)
    end
  end
end