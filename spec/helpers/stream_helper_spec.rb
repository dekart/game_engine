require "spec_helper"

describe StreamHelper do
  before :each do
    helper.stub!(:asset_image_path).and_return("/path/to/image.jpg")
  end

  describe "when generating stream dialog for level up" do
    before :each do
      @character = mock_model(Character,
        :level => 5
      )

      helper.stub!(:current_character).and_return(@character)
    end

    it "should not fail" do
      lambda{
        helper.character_level_up_stream_dialog
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for fight" do
    before :each do
      @victim = mock_model(Character,
        :level => 5
      )
      @fight  = mock_model(Fight, 
        :victim => @victim
      )
    end

    it "should not fail" do
      lambda{
        helper.fight_stream_dialog(@fight)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for inventory item" do
    before :each do
      @item_group = mock_model(ItemGroup)

      @inventory  = mock_model(Inventory,
        :name       => "Super Item",
        :item_group => @item_group,
        :image?     => true,
        :image      => mock("image", :url => "/path/to/image.jpg")
      )
    end

    it "should not fail" do
      lambda{
        helper.inventory_stream_dialog(@inventory)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for invitation" do
    before :each do
      @character = mock_model(Character,
        :invitation_key => "the-key"
      )

      helper.stub!(:current_character).and_return(@character)
    end

    it "should not fail" do
      lambda{
        helper.invitation_stream_dialog
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

    it "should not fail" do
      lambda{
        helper.mission_complete_stream_dialog(@mission)
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

    it "should not fail" do
      lambda{
        helper.boss_defeated_stream_dialog(@boss)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for help request" do
    before :each do
      @mission  = mock_model(Mission,
        :name           => "Super Mission"
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

    it "should not fail" do
      lambda{
        helper.property_stream_dialog(@property)
      }.should_not raise_exception
    end
  end

  describe "when generating stream dialog for promotion" do
    before :each do
      @promotion = mock_model(Promotion,
        :valid_till => 1.day.from_now
      )
    end

    it "should not fail" do
      lambda{
        helper.promotion_stream_dialog(@promotion)
      }.should_not raise_exception
    end
  end
end