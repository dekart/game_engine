require 'spec_helper'

describe MonsterFight do
  describe 'associations' do
    it "should belong to character" do
      should belong_to :character
    end

    it "should belong to monster" do
      should belong_to :monster
    end
  end

  describe 'when attacking monster' do
    before do
      @monster = Factory(:monster)

      @character = Factory(:character)

      @monster_fight = MonsterFight.new(:character => @character, :monster => @monster)
    end

    it 'should not be valid if character does not have enough stamina' do
      @character.sp = 0

      @monster_fight.should_not be_valid
      @monster_fight.errors.on(:character).should_not be_empty
    end

    it 'should not be valid if monster is not in the progress' do
      @monster.win

      @monster_fight.should_not be_valid
      @monster_fight.errors.on(:monster).should_not be_empty
    end

    describe 'when valid' do
      before do
        @damage_system = mock('damage system', :calculate_damage => [10, 20])

        MonsterFight.stub!(:damage_system).and_return(@damage_system)
      end

      it 'should calculate damage dealt to monster and character' do
        @damage_system.should_receive(:calculate_damage).with(@character, @monster).and_return([10, 20])

        @monster_fight.attack!
      end

      it 'should apply damage to monster' do
        lambda {
          @monster_fight.attack!
        }.should change(@monster, :hp).from(1000).to(980)
      end

      it 'should apply damage to character' do
        lambda {
          @monster_fight.attack!
        }.should change(@character, :hp).from(100).to(90)
      end

      it 'should apply experience reward to character' do
        lambda {
          @monster_fight.attack!
        }.should change(@character, :experience).from(0).to(5)
      end

      it 'should apply money reward to character' do
        lambda {
          @monster_fight.attack!
        }.should change(@character, :basic_money).from(0).to(5)
      end

      it 'should take stamina from character' do
        lambda {
          @monster_fight.attack!
        }.should change(@character, :sp).from(10).to(9)
      end

      it 'should append damage dealt to monster' do
        lambda {
          @monster_fight.attack!
        }.should change(@monster_fight, :damage).from(0).to(20)
      end

      it 'should save monster' do
        @monster_fight.attack!

        @monster.should_not be_changed
      end

      it 'should save character' do
        @monster_fight.attack!

        @character.should_not be_changed
      end

      it 'should be saved' do
        @monster_fight.attack!

        @monster_fight.should_not be_changed
      end
    end
  end
end