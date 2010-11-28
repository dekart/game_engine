require 'spec_helper'

describe Monster do
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
end