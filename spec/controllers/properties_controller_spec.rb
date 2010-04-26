require File.expand_path("../../spec_helper", __FILE__)

describe PropertiesController do
  include Facebooker::Rails::TestHelpers

  describe "when routing" do
    it "should correctly map to property list" do
      params_from(:get, "/properties").should == {:controller => "properties", :action => "index"}
    end

    it "should correctly map to property purchase" do
      params_from(:post, "/properties").should == {:controller => "properties", :action => "create"}
    end

    it "should correctly map to property upgrade" do
      params_from(:put, "/properties/1/upgrade").should == {:controller => "properties", :action => "upgrade", :id => "1"}
    end
  end
  
  describe "when purchasing a property" do
    before :each do
      @property_type = mock_model(PropertyType)

      @character_specific_types = mock(:character_types, :find => @property_type)
      @shop_and_special_types = mock(:shop_types, :available_for => @character_specific_types)

      PropertyType.stub!(:available_in).and_return(@shop_and_special_types)

      @property = mock_model(Property)

      @character_properties = mock(:properties, :buy! => @property)
      @character = mock_model(Character, :properties => @character_properties)

      controller.stub!(:current_character).and_return(@character)
    end

    it "should filter property types by availability" do
      PropertyType.should_receive(:available_in).with(:shop, :special).and_return(@shop_and_special_types)

      facebook_post :create, :property_type_id => 1
    end

    it "should filter property types by availability for character" do
      @shop_and_special_types.should_receive(:available_for).with(@character).and_return(@character_specific_types)

      facebook_post :create, :property_type_id => 1
    end

    it "should find property type by ID" do
      @character_specific_types.should_receive(:find).with("1").and_return(@property_type)

      facebook_post :create, :property_type_id => 1
    end
    
    it "should buy a property" do
      @character_properties.should_receive(:buy!).with(@property_type).and_return(@property)

      facebook_post :create, :property_type_id => 1

      assigns[:property].should == @property
    end
    
    it "should fetch character properties without cache" do
      @character.should_receive(:properties).with(true).and_return(@character_properties)

      facebook_post :create, :property_type_id => 1

      assigns[:properties].should == @character_properties
    end

    it "should render AJAX response" do
      facebook_post :create, :property_type_id => 1

      response.should render_template("create")
      response.should use_layout("ajax")
    end
  end

  describe "when upgrading a property" do
    before :each do
      @property = mock_model(Property, :upgrade => true)

      @character_properties = mock(:properties, :find => @property)

      @character = mock_model(Character, :properties => @character_properties)

      controller.stub!(:current_character).and_return(@character)
    end

    it "should fetch the property from the database" do
      @character.properties.should_receive(:find).with("1").and_return(@property)

      facebook_put :upgrade, :id => 1

      assigns[:property].should == @property
    end
    
    it "should upgrade the property" do
      @property.should_receive(:upgrade).and_return(true)

      facebook_put :upgrade, :id => 1
    end
    
    it "should fetch character properties without cache" do
      @character.should_receive(:properties).with(true).and_return(@character_properties)

      facebook_post :upgrade, :id => 1

      assigns[:properties].should == @character_properties
    end

    it "should render AJAX response" do
      facebook_post :upgrade, :id => 1

      response.should render_template("upgrade")
      response.should use_layout("ajax")
    end
  end
end