require File.expand_path("../../../spec_helper", __FILE__)

describe Character do
  before :each do
    @property_type = Factory(:property_type)
    
    @character = Factory(:character)
  end

  describe "when giving a property" do
    describe "if user doesn't have this property" do
      it "should add property" do
        lambda{
          @character.properties.give!(@property_type)
        }.should change(@character.properties, :count).from(0).to(1)
      end
    end

    describe "if user already has this property" do
      before :each do
        @character.properties.create(:property_type => @property_type)
      end

      it "shouldn't add property" do
        lambda{
          @character.properties.give!(@property_type)
        }.should_not change(@character.properties, :count)
      end
    end

    it "should return an instance of Property class" do
      @character.properties.give!(@property_type).should be_instance_of(Property)
    end
  end

  describe "when buying properties" do
    describe "if the property doesn't exist" do
      it "should add a property to user" do
        lambda{
          @character.properties.buy!(@property_type)
        }.should change(@character.properties, :count)
      end
    end

    describe "if the property already exist" do
      before :each do
        @character.properties.create(:property_type => @property_type)
      end

      it "shouldn't add a property to user" do
        lambda{
          @character.properties.buy!(@property_type)
        }.should_not change(@character.properties, :count)
      end
    end

    it "should return an instance of Property class" do
      @character.properties.buy!(@property_type).should be_instance_of(Property)
    end
  end
end

