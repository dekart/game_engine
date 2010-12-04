require 'spec_helper'

describe Monster do
  describe 'associations' do
    it 'should belong to character' do
      should belong_to :character
    end

    it 'should belong to monster type' do
      should belong_to :monster_type
    end

    it 'should have many monster fights' do
      should have_many :monster_fights
    end
  end

  describe "delegations" do
    before do
      @monster_type = Factory(:monster_type)
      @monster = @monster_type.monsters.create(:character => Factory(:character))
    end

    %w{name health level cooling_time experience money minimum_damage maximum_damage minimum_response maximum_response}.each do |attribute|
      it "should delegate #{attribute.humanize} to monster type" do
        @monster.send(attribute).should == @monster_type.send(attribute)
      end
    end

    it "should delegate image to monster type" do
      @monster.image.instance.should == @monster_type
    end

    it "should delegate requirements to monster type" do
      @monster.requirements.size.should == @monster_type.requirements.size
    end
  end

  describe 'when creating' do
    before do
      @character = Factory.create(:character)
      @monster_type = Factory.create(:monster_type)
      
      @monster = Monster.new(
        :character    => @character,
        :monster_type => @monster_type
      )
    end

    it "should be invalid without assigned character" do
      @monster.character = nil

      @monster.should_not be_valid
      @monster.errors.on(:character).should_not be_empty
    end

    it "should be invalid without assigned monster type" do
      @monster.monster_type = nil

      @monster.should_not be_valid
      @monster.errors.on(:monster_type).should_not be_empty
    end

    it "should be invalid if cooling time haven't passed" do
      @other_monster = Monster.create!(:character => @character, :monster_type => @monster_type)
      
      Monster.update_all({:created_at => (24.hours - 1.minute).ago}, {:id => @other_monster.id})

      @monster.should_not be_valid
      @monster.errors.on(:base).should_not be_empty
    end

    it "should be invalid if character's level is lower than required" do
      @monster.monster_type = Factory.create(:monster_type, :level => 2)

      @monster.should_not be_valid
      @monster.errors.on(:character).should_not be_empty
    end

    it "should be invalid if requirements are not satisfied" do
      @monster.monster_type = Factory.create(:monster_type,
        :requirements => Requirements::Collection.new(
          Requirements::Attack.new(:value => 10_000)
        )
      )

      @monster.should_not be_valid
      @monster.errors.on(:character).should_not be_empty
    end

    describe 'when valid' do
      it 'should assign its health points to default value' do
        lambda { @monster.save }.should change(@monster, :hp).to(1000)
      end

      it 'should apply fight start payouts to character' do
        @monster.monster_type = Factory.create(:monster_type,
          :payouts => Payouts::Collection.new(
            Payouts::UpgradePoint.new(:value => 100, :apply_on => :fight_start)
          )
        )

        lambda { @monster.save }.should change(@character, :points).from(0).to(100)
        
        @monster.payouts.should be_kind_of(Payouts::Collection)
        @monster.payouts.first.should be_kind_of(Payouts::UpgradePoint)
      end

      it "should assign expiration time" do
        @monster.save
        (@monster.expire_at.to_i - 12.hours.from_now.to_i).should == 0
      end

      it "should create monster fight record for character" do
        lambda { @monster.save }.should change(@character.monster_fights, :count).from(0).to(1)

        @character.monster_fights.first.monster.should == @monster
      end
    end
  end

  describe 'when updating' do
    before do
      @monster = Factory(:monster)
    end

    it 'should set health to 0 if it went below zero' do
      @monster.hp = -10

      lambda{
        @monster.save
      }.should change(@monster, :hp).to(0)
    end

    it 'should become won if in progress and health dropped to zero' do
      @monster.hp = 0

      lambda {
        @monster.save
      }.should change(@monster, :state).from('progress').to('won')
    end

    it 'should stay in progress if health is greater than 0' do
      @monster.hp = 1
      
      lambda {
        @monster.save
      }.should_not change(@monster, :state)
    end
  end

  describe "when checking cooling time passed" do
    before do
      @monster = Factory(:monster)
    end

    it "should return false if monster was created less than 24 hours ago" do
      @monster.cooling_time_passed?.should be_false
    end

    it "should return true if monster was created more than 24 hours ago" do
      Monster.update_all({:created_at => (24.hours + 1.minute).ago}, {:id => @monster.id})

      @monster.reload
      
      @monster.cooling_time_passed?.should be_true
    end
  end

  describe "scopes" do
    describe "when fetching visible monsters" do
      it "should fetch monsters who expired less than 5 days ago" do
        @monster1 = Factory.create(:monster)
        @monster2 = Factory.create(:monster)

        Monster.update_all({:expire_at => (Setting.i(:monster_display_time).days + 1.minute).ago}, {:id => @monster2.id})

        Monster.visible.should include(@monster1)
        Monster.visible.should_not include(@monster2)
      end

      it "should fetch monsters defeated less than 5 days ago" do
        @monster1 = Factory.create(:monster)
        @monster2 = Factory.create(:monster, :defeated_at => (Setting.i(:monster_display_time).days + 1.minute).ago)

        Monster.visible.should include(@monster1)
        Monster.visible.should_not include(@monster2)
      end
    end
  end
end