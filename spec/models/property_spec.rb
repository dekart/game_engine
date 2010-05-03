require File.expand_path("../../spec_helper", __FILE__)

describe Property do
  before(:each) do
    @property_type = Factory(:property_type)

    @property = Property.new(:property_type => @property_type)

    @character = Factory(:character)

    @property.character = @character
  end

  [:name, :plural_name, :description, :image, :image?, :basic_price, :vip_price, :income, :collect_period].each do |method|
    it "should delegate :#{method} method to property type" do
      @property.send(method).should === @property_type.send(method)
    end
  end

  it "should have level 1 by default" do
    @property.level.should == 1
  end

  it "should be already collected by default" do
    @property.save
    
    @property.collected_at.should == @property.created_at
  end

  it "should return correct total income" do
    @property.level = 5
    
    @property.total_income.should == 50
  end

  it "should return correct upgrade price" do
    @property.level = 5

    @property_type.should_receive(:upgrade_price).with(5).and_return(123)

    @property.upgrade_price.should == 123
  end

  describe "when asking for maximum upgrade level" do
    it "should return zero when no value specified in property type and settings" do
      Setting.should_receive(:i).and_return 0

      @property.maximum_level.should == 0
    end

    it "should return settings value if no value specified in property type" do
      Setting.should_receive(:i).and_return 5

      @property.maximum_level.should == 5
    end

    it "should return value from property type when specified" do
      @property_type.should_receive(:upgrade_limit).and_return 10

      @property.maximum_level.should == 10
    end
  end

  describe "when asking if property is collectable" do
    it "should return false if time since last collection is less than collection period" do
      @property.collected_at = Time.now - 59.minutes

      @property.should_not be_collectable
    end

    it "should return true if time since last collection is more than collection period" do
      @property.collected_at = Time.now - 61.minutes

      @property.should be_collectable
    end
  end

  shared_examples_for "character validation" do
    def character_should_have_enough_money(currency, suffix = nil)
      @character.send("#{currency}=", 0)

      yield

      @property.errors.on(:character).should include(
        I18n.t("activerecord.errors.models.property.attributes.character.not_enough_#{currency}" + (suffix ? "_#{suffix}" : ""),
          :name     => "Property Type",
          currency  => Character.human_attribute_name(currency)
        )
      )
    end
  end

  describe "when buying a property" do
    it_should_behave_like "character validation"

    it "should add new property instance" do
      lambda{
        @property.buy!.should be_true
      }.should change(@character.properties, :count).from(0).to(1)
      
    end

    it "should verify that character has enough basic money" do
      character_should_have_enough_money(:basic_money) do
        @property.buy!.should be_false
      end
    end

    it "should verify that character has enough vip money" do
      character_should_have_enough_money(:vip_money) do
        @property.buy!.should be_false
      end
    end

    it "should charge character for basic_money" do
      lambda{
        @property.buy!
      }.should change(@character, :basic_money).from(1100).to(100)
    end

    it "should charge character for vip_money" do
      lambda{
        @property.buy!
      }.should change(@character, :vip_money).from(1).to(0)
    end
  end

  describe "when upgrading a property" do
    it_should_behave_like "character validation"

    before :each do
      @property.save!
    end
    
    it "should check that the property not newly created" do
      @property = Property.new

      @property.upgrade!.should == false
    end
    
    it "should verify that character has enough basic money" do
      character_should_have_enough_money(:basic_money, :for_upgrade) do
        @property.upgrade!.should be_false
      end
    end
    
    it "should verify that character has enough vip money" do
      character_should_have_enough_money(:vip_money, :for_upgrade) do
        @property.upgrade!.should be_false
      end
    end

    it "should change property level" do
      lambda{
        @property.upgrade!
      }.should change(@property, :level).from(1).to(2)
    end

    it "should save the record" do
      @property.upgrade!

      @property.should_not be_changed
    end

    it "should charge character for basic_money" do
      lambda{
        @property.upgrade!
      }.should change(@character, :basic_money).from(1100).to(0)
    end

    it "should charge character for vip_money" do
      lambda{
        @property.upgrade!
      }.should change(@character, :vip_money).from(1).to(0)
    end
  end

  describe "when collecting money from property" do
    before :each do
      @property.save!
    end

    describe "if property is not collectable" do
      it "should return false" do
        @property.collect_money!.should be_false
      end
      
      it "shouldn't change collection time" do
        lambda{
          @property.collect_money!
        }.should_not change(@property, :collected_at)
      end
      
      it "shouldn't change character money" do
        lambda{
          @property.collect_money!
        }.should_not change(@property.character, :basic_money)
      end
    end

    describe "if property is collectable" do
      before :each do
        @property.update_attribute(:collected_at, 61.minutes.ago)
      end

      it "should update collection time" do
        lambda{
          @property.collect_money!
        }.should change(@property, :collected_at)
      end

      it "should give collected money to character" do
        lambda{
          @property.collect_money!
        }.should change(@property.character, :basic_money).from(1100).to(1110)
      end

      it "should return amount of collected money" do
        @property.collect_money!.should == 10
      end
    end
  end
end