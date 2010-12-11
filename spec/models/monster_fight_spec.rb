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

  it 'should use simple damage calculation system' do
    MonsterFight.damage_system.should == FightingSystem::PlayerVsMonster::Simple
  end

  describe 'when attacking monster' do
    before do
      @monster = Factory(:monster)

      @character = Factory(:character)

      @monster_fight = MonsterFight.create(:character => @character, :monster => @monster)

      @damage_system = mock('damage system', :calculate_damage => [10, 20])

      MonsterFight.stub!(:damage_system).and_return(@damage_system)
    end

    it 'should return false if character does not have enough stamina' do
      @character.sp = 0

      @monster_fight.attack!.should be_false
    end

    it 'should return false if monster is not in the progress' do
      @monster.win

      @monster_fight.attack!.should be_false
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

    it 'should store damage dealt to monster to a variable' do
      lambda {
        @monster_fight.attack!
      }.should change(@monster_fight, :monster_damage).from(nil).to(20)
    end

    it 'should apply damage to character' do
      lambda {
        @monster_fight.attack!
      }.should change(@character, :hp).from(100).to(90)
    end

    it 'should store damage dealt to character to a variable' do
      lambda {
        @monster_fight.attack!
      }.should change(@monster_fight, :character_damage).from(nil).to(10)
    end

    it 'should apply experience reward to character' do
      lambda {
        @monster_fight.attack!
      }.should change(@character, :experience).from(0).to(5)
    end

    it 'should store experience reward to a variable' do
      lambda {
        @monster_fight.attack!
      }.should change(@monster_fight, :experience).from(nil).to(5)
    end

    it 'should apply money reward to character' do
      lambda {
        @monster_fight.attack!
      }.should change(@character, :basic_money).from(0).to(5)
    end

    it 'should store money reward to a variable' do
      lambda {
        @monster_fight.attack!
      }.should change(@monster_fight, :money).from(nil).to(5)
    end

    it 'should take stamina from character' do
      lambda {
        @monster_fight.attack!
      }.should change(@character, :sp).from(10).to(9)
    end

    it 'should store stamina spending to a variable' do
      lambda {
        @monster_fight.attack!
      }.should change(@monster_fight, :stamina).from(nil).to(1)
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

    it 'should return true' do
      @monster_fight.attack!.should be_true
    end
  end

  describe 'when checking if reward is collectable' do
    before do
      @monster_fight = Factory(:monster_fight)
    end

    it 'should return true if monster is won and reward is not collected' do
      @monster_fight.monster.win

      @monster_fight.reward_collectable?.should be_true
    end

    it 'should return false if monster is not won' do
      @monster_fight.monster.expire

      @monster_fight.reward_collectable?.should_not be_true
    end

    it 'should return false if reward is already collected' do
      @monster_fight.monster.win
      @monster_fight.reward_collected = true

      @monster_fight.reward_collectable?.should_not be_true
    end
  end

  describe 'when applying reward' do
    before do
      @character = Factory(:character)
      
      @monster_fight = Factory(:monster_fight, :character => @character)
      @monster_fight.monster.win
    end

    it 'should return false if reward is not collectable' do
      @monster_fight.should_receive(:reward_collectable?).and_return(false)

      @monster_fight.collect_reward!.should be_false
    end

    it 'should apply victory payout when this fight is not repeat fight' do
      @monster_fight.should_receive(:repeat_fight?).and_return(false)

      lambda {
        @monster_fight.collect_reward!
      }.should change(@character, :basic_money).to(123)
    end

    it 'should apply repeat victory payout when this fight is repeat fight' do
      @monster_fight.should_receive(:repeat_fight?).and_return(true)

      lambda{
        @monster_fight.collect_reward!
      }.should change(@character, :basic_money).to(456)
    end

    it 'should store applied payouts to a variable' do
      @monster_fight.collect_reward!

      @monster_fight.payouts.should be_kind_of(Payouts::Collection)
      
      @monster_fight.payouts.first.should be_kind_of(Payouts::BasicMoney)
      @monster_fight.payouts.first.value.should == 123
    end

    it 'should become collected' do
      @monster_fight.collect_reward!

      @monster_fight.reward_collected?.should be_true
      @monster_fight.reload.reward_collected?.should be_true
    end

    it 'should return true on successfull collection' do
      @monster_fight.collect_reward!.should be_true
    end
  end

  describe 'when checking if fight is repeat fight' do
    before do
      @monster_fight = Factory(:monster_fight)
    end

    it 'should return false if there is no won fights with this monster type' do
      @monster_fight.repeat_fight?.should be_false
    end

    it 'should return false if there is no won fight with this monster type and the fight is won' do
      @monster_fight.monster.win

      @monster_fight.repeat_fight?.should be_false
    end
    
    it 'should return true if there is a won fight with this monster type' do
      @second_monster = Factory(:monster, :monster_type => @monster_fight.monster.monster_type)
      @second_monster_fight = Factory(:monster_fight, :character => @monster_fight.character, :monster => @second_monster)
      @second_monster.win

      @monster_fight.repeat_fight?.should be_true
    end
  end

  describe 'when getting payout triggers' do
    before do
      @monster_fight = Factory(:monster_fight)
    end

    it 'should return :victory if it\'s not a repeat fight' do
      @monster_fight.payout_triggers.should == [:victory]
    end

    it 'should return :repeat_victory if it\'s a repeat fight' do
      @monster_fight.should_receive(:repeat_fight?).and_return true

      @monster_fight.payout_triggers.should == [:repeat_victory]
    end

    it 'should return empty array if reward is already collected' do
      @monster_fight.reward_collected = true

      @monster_fight.payout_triggers.should == []
    end
  end

  describe 'when getting stamina requirement' do
    before do
      @monster_fight = Factory(:monster_fight)
    end

    it 'should return requirement for 1 stamina point' do
      @monster_fight.stamina_requirement.should be_kind_of(Requirements::StaminaPoint)
      @monster_fight.stamina_requirement.value.should == 1
    end
  end
end