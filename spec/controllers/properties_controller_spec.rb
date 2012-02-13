require File.expand_path("../../spec_helper", __FILE__)

describe PropertiesController do
  before do
    controller.stub!(:current_facebook_user).and_return(fake_fb_user)
  end
  
  describe "when routing" do
    it "should correctly map to property list" do
      {:get => "/properties"}.should route_to(
        :controller => "properties",
        :action     => "index"
      )
    end

    it "should correctly map to property purchase" do
      {:post => "/properties"}.should route_to(
        :controller => "properties",
        :action     => "create"
      )
    end

    it "should correctly map to property upgrade" do
      {:put => "/properties/1/upgrade"}.should route_to(
        :controller => "properties",
        :action     => "upgrade",
        :id         => "1"
      )
    end

    it "should correctly map to property collect money for a single property" do
      {:put => "/properties/1/collect_money"}.should route_to(
        :controller => "properties",
        :action     => "collect_money",
        :id         => "1"
      )
    end

    it "should correctly map to property collect money for property collection" do
      {:put => "/properties/collect_money"}.should route_to(
        :controller => "properties",
        :action     => "collect_money"
      )
    end
  end

  describe "when listing properties" do
    before :each do
      @character = mock_model(Character, :properties => [])

      controller.stub!(:current_character).and_return(@character)
    end

    it "should succesfully render" do
      get :index

      response.should be_success
    end
  end
  
  describe "when purchasing a property" do
    before :each do
      @property_type = mock_model(PropertyType)

      @character_specific_types = mock(:character_types, :find => @property_type)
      @shop_and_special_types = mock(:shop_types, :available_for => @character_specific_types)

      PropertyType.stub!(:available_in).and_return(@shop_and_special_types)

      @property = mock_model(Property, :errors => [], :event_data => {})

      @character_properties = mock(:properties, :buy! => @property)
      @character = mock_model(Character, :properties => @character_properties, :event_data => {})

      @property.stub!(:character).and_return(@character)
      controller.stub!(:current_character).and_return(@character)
    end

    it "should filter property types by availability" do
      PropertyType.should_receive(:available_in).with(:shop, :special).and_return(@shop_and_special_types)

      post :create, :property_type_id => 1, :format => :js
    end

    it "should filter property types by availability for character" do
      @shop_and_special_types.should_receive(:available_for).with(@character).and_return(@character_specific_types)

      post :create, :property_type_id => 1, :format => :js
    end

    it "should find property type by ID" do
      @character_specific_types.should_receive(:find).with("1").and_return(@property_type)

      post :create, :property_type_id => 1, :format => :js
    end
    
    it "should buy a property" do
      @character_properties.should_receive(:buy!).with(@property_type).and_return(@property)

      post :create, :property_type_id => 1, :format => :js

      assigns[:property].should == @property
    end

    it "should be checked for errors" do
      post :create, :property_type_id => 1, :format => :js

      assigns[:property].should == @property
    end

    describe "if a property was purchased successfully" do
      it "should log the event" do
          post :create, :property_type_id => 1, :format => :js

          assigns[:property].should == @property
      end
    end

    it "should fetch character properties without cache and pass them to the template" do
      @character.should_receive(:properties).with(true).and_return(@character_properties)

      post :create, :property_type_id => 1, :format => :js

      assigns[:properties].should == @character_properties
    end

    it "should render AJAX response" do
      post :create, :property_type_id => 1, :format => :js

      response.should render_template("create")
    end
  end

  describe "when upgrading a property" do
    before :each do
      @property_type = mock_model(PropertyType, :upgrade_price => 0)
      @property = mock_model(Property, 
        :upgrade! => true, 
        :errors => [], 
        :event_data => {}, 
        :property_type => @property_type,
        :level => 1)

      @character_properties = mock(:properties, :find => @property)

      @character = mock_model(Character, :properties => @character_properties, :event_data => {})

      @property.stub!(:character).and_return(@character)
      controller.stub!(:current_character).and_return(@character)
    end

    it "should fetch the property from the database" do
      @character.properties.should_receive(:find).with("1").and_return(@property)

      put :upgrade, :id => 1, :format => :js

      assigns[:property].should == @property
    end
    
    it "should upgrade the property" do
      @property.should_receive(:upgrade!).and_return(true)

      put :upgrade, :id => 1, :format => :js
    end

    it "should be checked for errors" do
      @property.should_receive(:errors).and_return([])

      put :upgrade, :id => 1, :format => :js
    end

    it "should fetch character properties without cache and pass them to the template" do
      @character.should_receive(:properties).with(true).and_return(@character_properties)

      post :upgrade, :id => 1, :format => :js

      assigns[:properties].should == @character_properties
    end

    it "should render AJAX response" do
      post :upgrade, :id => 1, :format => :js

      response.should render_template("upgrade")
    end
  end

  describe "when collecting money from properties" do
    before :each do
      @property = mock_model(Property, :collect_money! => true, :event_data => {})

      @character_properties = mock(:properties, 
        :find => @property,
        :collect_money! => true,
        :each => Proc.new {yield @property}
      )

      @character = mock_model(Character, :properties => @character_properties, :event_data => {})

      @property.stub!(:character).and_return(@character)

      controller.stub!(:current_character).and_return(@character)
    end

    describe "when collecting money from a single property" do
      it "should fetch a property from character the database and pass it to the template" do
        @character_properties.should_receive(:find).with("1").and_return(@property)

        put :collect_money, :id => 1, :format => :js
      end

      it "should collect money from it and pass result to the template" do
        @property.should_receive(:collect_money!).and_return(123)

        put :collect_money, :id => 1, :format => :js

        assigns[:result].should == 123
      end

      it "should log the collecting event for property" do
        put :collect_money, :id => 1, :format => :js
      end

      it "should pass the property to the template" do
        put :collect_money, :id => 1, :format => :js

        assigns[:property].should == @property
      end

      it "should fetch character properties and pass the to the template" do
        @character.should_receive(:properties).and_return(@character_properties)

        post :collect_money, :id => 1, :format => :js

        assigns[:properties].should == @character_properties
      end

      it "should render AJAX response for a single property" do
        post :collect_money, :id => 1, :format => :js

        response.should render_template("collect_money")
      end
    end

    describe "when collecting money from property collection" do
      it "should collect money for character properties and pass result to the template" do
        @character_properties.should_receive(:collect_money!).and_return(456)

        put :collect_money, :format => :js

        assigns[:result].should == 456
      end

      it "should pass character properties to the template" do
        put :collect_money, :format => :js

        assigns[:properties].should == @character_properties
      end

      it "should render AJAX response for property collection" do
        post :collect_money, :format => :js

        response.should render_template("collect_money")
      end
    end
  end
end