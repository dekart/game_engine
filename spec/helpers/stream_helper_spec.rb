require "spec_helper"

describe StreamHelper do
  before :each do
    helper.stub!(:asset_image_path).and_return("/path/to/image.jpg")
    helper.stub!(:current_character).and_return(mock_model(Character))
    helper.stub!(:reference_code).and_return("The code")
    
    helper.stub!(:encryptor).and_return(
      mock('encryptor', :encrypt => 'asd123')
    )
  end

  describe "when generating stream dialog for level up" do
    before :each do
      @character = mock_model(Character,
        :level => 5
      )

      helper.stub!(:current_character).and_return(@character)
    end

    it "should not fail with default story" do
      lambda{
        helper.stream_dialog(:level_up)
      }.should_not raise_exception
    end
    
    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:level_up).and_return([@story])

      lambda{
        helper.stream_dialog(:level_up)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for inventory item" do
    before :each do
      @item_group = mock_model(ItemGroup)

      @item = mock_model(Item,
        :name       => "Super Item",
        :item_group => @item_group,
        :image?     => true,
        :image      => mock("image", :url => "/path/to/image.jpg")
      )
    end

    it "should not fail with default story" do
      lambda{
        helper.stream_dialog(:item_purchased, @item)
      }.should_not raise_exception
    end
    
    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:item_purchased).and_return([@story])

      lambda{
        helper.stream_dialog(:item_purchased, @item)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for mission completion" do
    before :each do
      @mission_group = mock_model(MissionGroup)

      @mission  = mock_model(Mission,
        :name           => "Super Mission",
        :mission_group  => @mission_group,
        :image?         => true,
        :image          => mock("image", :url => "/path/to/image.jpg")
      )
    end

    it "should not fail with default options" do
      lambda{
        helper.stream_dialog(:mission_completed, @mission)
      }.should_not raise_exception
    end
    
    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:mission_completed).and_return([@story])

      lambda{
        helper.stream_dialog(:mission_completed, @mission)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for boss defeat" do
    before :each do
      @mission_group = mock_model(MissionGroup)

      @boss  = mock_model(Boss,
        :name           => "Super Boss",
        :mission_group  => @mission_group,
        :image?         => true,
        :image          => mock("image", :url => "/path/to/image.jpg")
      )
    end

    it "should not fail with default story" do
      lambda{
        helper.stream_dialog(:boss_defeated, @boss)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:boss_defeated).and_return([@story])

      lambda{
        helper.stream_dialog(:boss_defeated, @boss)
      }.should_not raise_exception
    end
  end

  describe 'when generating stream dialog for monster fight invitation' do
    before do
      @monster = mock_model(Monster,
        :name => 'Fake Monster',
        :image? => true,
        :image  => mock("image", :url => "/path/to/image.jpg")
      )
    end
    
    it 'should not fail with default story' do
      lambda{
        helper.stream_dialog(:monster_invite, @monster)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:monster_invite).and_return([@story])

      lambda{
        helper.stream_dialog(:monster_invite, @monster)
      }.should_not raise_exception
    end
  end
  
  describe 'when generating stream dialog for monster defeat' do
    before do
      @monster = mock_model(Monster,
        :name => 'Fake Monster',
        :image? => true,
        :image  => mock("image", :url => "/path/to/image.jpg")
      )
    end
    
    it 'should not fail with default story' do
      lambda{
        helper.stream_dialog(:monster_defeated, @monster)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:monster_defeated).and_return([@story])

      lambda{
        helper.stream_dialog(:monster_defeated, @monster)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for help request" do
    before :each do
      @mission_group = mock_model(MissionGroup)

      @mission  = mock_model(Mission,
        :name           => "Super Mission",
        :mission_group  => @mission_group,
        :image?         => true,
        :image          => mock("image", :url => "/path/to/image.jpg")
      )

      @victim = mock_model(Character,
        :level => 5
      )
      @fight = mock_model(Fight, :victim => @victim)

      @character = mock_model(Character)

      helper.stub!(:current_character).and_return(@character)
    end

    it "should not fail for missions" do
      lambda{
        helper.help_request_stream_dialog(@mission)
      }.should_not raise_exception
    end

    it "should not fail for fights" do
      lambda{
        helper.help_request_stream_dialog(@fight)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for property" do
    before :each do
      @property = mock_model(Property,
        :name   => "Super Property",
        :image? => true,
        :image  => mock("image", :url => "/path/to/image.jpg")
      )
    end

    it "should not fail with default story" do
      lambda{
        helper.stream_dialog(:property, @property)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:property).and_return([@story])

      lambda{
        helper.stream_dialog(:property, @property)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for promotion" do
    before :each do
      @promotion = mock_model(Promotion,
        :valid_till => 1.day.from_now
      )
    end

    it "should not fail with default story" do
      lambda{
        helper.stream_dialog(:promotion, @promotion)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:promotion).and_return([@story])

      lambda{
        helper.stream_dialog(:promotion, @promotion)
      }.should_not raise_exception
    end
  end
  
  describe 'when generating stream dialog for new hit listing' do
    before do
      @listing = mock_model(HitListing,
        :reward => 1000,
        :victim => mock_model(Character, :level => 123)
      )
    end
    
    it 'should not fail with default story' do
      lambda{
        helper.stream_dialog(:hit_listing_new, @listing)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:hit_listing_new).and_return([@story])

      lambda{
        helper.stream_dialog(:hit_listing_new, @listing)
      }.should_not raise_exception
    end
  end
  
  describe 'when generating stream dialog for completed hit listing' do
    before do
      @listing = mock_model(HitListing,
        :reward => 1000,
        :victim => mock_model(Character, :level => 123)
      )
    end
    
    it 'should not fail with default story' do
      lambda{
        helper.stream_dialog(:hit_listing_completed, @listing)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:hit_listing_completed).and_return([@story])

      lambda{
        helper.stream_dialog(:hit_listing_completed, @listing)
      }.should_not raise_exception
    end
  end

  describe 'when generating stream dialog for completed collection' do
    before do
      @collection = mock_model(ItemCollection,
        :name => 'Fake Collection'
      )
    end
    
    it 'should not fail with default story' do
      lambda{
        helper.stream_dialog(:collection_completed, @collection)
      }.should_not raise_exception
    end

    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:collection_completed).and_return([@story])

      lambda{
        helper.stream_dialog(:collection_completed, @collection)
      }.should_not raise_exception
    end
  end

  describe 'when generating stream dialog for missing collection items' do
    before do
      @collection = mock_model(ItemCollection,
        :name => 'Fake Collection',
        :missing_items => [mock_model(Item, :name => 'Fake Item')]
      )
      
      helper.stub!(:current_character).and_return(mock_model(Character))
    end
    
    it 'should not fail' do
      lambda{
        helper.stream_dialog(:collection_missing_items, @collection)
      }.should_not raise_exception
    end
    
    it 'should not fail with custom story' do
      @story = mock_model(Story, 
        :interpolate  => 'text',
        :image?       => true,
        :image        => mock("image", :url => "/path/to/image.jpg")
      )
      
      Story.should_receive(:by_alias).with(:collection_missing_items).and_return([@story])

      lambda{
        helper.stream_dialog(:collection_missing_items, @collection)
      }.should_not raise_exception
    end    
  end
end