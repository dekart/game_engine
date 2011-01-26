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
    
    %w{alias title description action_link}.each do |attribute|
      it "should require #{attribute} to be set" do
        @story.should validate_presence_of(attribute)
      end
    end

    it 'should successfully save' do
      @story.save.should be_true
    end
  end
  
  describe 'when finding by alias' do
    before do
      @story1 = Factory(:story)
      @story2 = Factory(:story)
      @story3 = Factory(:story)
      @story4 = Factory(:story, :alias => 'nonmatchingalias')
      
      @story1.publish
      @story2.publish
    end
    
    it 'should find visible stories only' do
      Story.by_alias('fake_story').should_not include(@story3)
    end
    
    it 'should find stories with matching alias' do
      Story.by_alias('fake_story').should_not include(@story4)
    end
    
    it 'should order stories randomly' do
      Story.by_alias('fake_story').proxy_options[:order].should =~ /RAND\(\)/
    end
    
    it 'should work with symbols as well as with strings' do
      Story.by_alias(:fake_story).should include(@story1, @story2)
    end
  end
  
  describe 'when interpolating attributes' do
    before do
      @story = Factory(:story, 
        :title => 'This is title with %{value}', 
        :description => 'This is description with %{value}'
      )
    end
    
    describe 'when interpolating single attribute' do
      it 'should raise exception when passed unallowed attribute value' do
        lambda {
          @story.interpolate(:state)
        }.should raise_exception(ArgumentError)
      end
    
      %w{title description action_link}.each do |attribute|
        it "should successfully interpolate #{attribute}" do
          @story[attribute] = 'Text with %{value}'
        
          @story.interpolate(attribute, :value => 123).should == 'Text with 123'
        end
      end
    
      it 'should return nil when attribute is blank' do
        @story.description = ''
      
        @story.interpolate(:description, :value => "asd").should be_nil
      end
    
      it 'should insert passed value into text' do
        @story.interpolate(:title, :value => 123).should == 'This is title with 123'
      end
    end
    
    describe 'when interpolating an array of attributes' do
      it 'should return an array of texts with inserted values' do
        @story.interpolate([:title, :description], :value => 123).should == ['This is title with 123', 'This is description with 123']
      end
    end
  end
  
  describe 'when tracking story visit' do
    before do
      @character = Factory(:character)
      @story = Factory(:story, :payouts => Payouts::Collection.new(DummyPayout.new(:apply_on => :visit)))
    end
    
    it 'should create story visit record for current character, story type, and story reference' do
      lambda{
        @story.track_visit!(@character)
      }.should change(StoryVisit, :count).from(0).to(1)
    end
    
    it 'should apply payouts to character' do
      @story.track_visit!(@character)
      
      @story.payouts.first.should be_applied
    end
    
    it 'should return payout result' do
      result = @story.track_visit!(@character)
      
      result.should be_kind_of(Payouts::Collection)
      result.first.should be_applied
    end
    
    describe 'when story is already visited' do
      before do
        StoryVisit.create(:character_id => @character.id, :story_alias => @story.alias)
      end
      
      it 'should not create visit record' do
        lambda{
          @story.track_visit!(@character)
        }.should_not change(StoryVisit, :count)
      end
      
      it 'should not apply payouts'
      
      it 'should return empty array' do
        @story.track_visit!(@character).should == []
      end
    end
  end
end