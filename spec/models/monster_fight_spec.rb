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

  describe 'scopes' do
    describe 'top damage scope' do
      before do
        @monster = Factory(:monster)
        @fight1 = @monster.monster_fights.first
        @fight2 = Factory(:monster_fight, :monster => @monster, :damage => 100)
      end
      
      it 'should order fights by most damage dealt' do
        MonsterFight.top_damage.should == [@fight2, @fight1]
      end
    end
  end

  it 'should use simple damage calculation system' do
    MonsterFight.damage_system.should == FightingSystem::PlayerVsMonster::Simple
  end
  
  describe 'when creating' do
    before do
      @monster = Factory(:monster)
      @character = Factory(:character)
      
      @monster_fight = MonsterFight.new(:monster => @monster, :character => @character)
    end
    
    it 'should create news about monster fight start' do
      lambda{
        @monster_fight.save
      }.should change(@character.news, :count).from(0).to(1)
      
      @character.news.first.monster_fight.should == @monster_fight
    end
    
    it 'should fail when character already fights with this monster' do
      MonsterFight.create(:monster => @monster, :character => @character)
      
      @monster_fight.save.should be_false
      @monster_fight.should_not be_valid
      @monster_fight.errors.on(:character_id).should_not be_empty
    end
  end

  describe '#attack' do
    before do
      @monster = Factory(:monster, :monster_type => Factory(:monster_type, :experience => 1))

      @character = Factory(:character)

      @monster_fight = MonsterFight.create(:character => @character, :monster => @monster)

      @damage_system = mock('damage system', :calculate_damage => [10, 20])

      MonsterFight.stub!(:damage_system).and_return(@damage_system)
    end
    
    it 'expire monster if its time is up and return false' do
      @monster.update_attribute(:expire_at, 1.second.ago)
      
      lambda{
        @monster_fight.attack!.should be_false
      }.should change(@monster, :expired?).from(false).to(true)
    end

    it 'should return false if character does not have enough stamina' do
      @character.sp = 0

      @monster_fight.attack!.should be_false
    end
    
    it 'should return false if character is weak' do
      @character.should_receive(:weak?).and_return(true)
      
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
    
    # test monster attack and power attack
    [
      {:who => :@monster, :what => :hp, :from => 1000, :to => 980},
      {:who => :@monster_fight, :what => :monster_damage, :from => nil, :to => 20},
      {:who => :@character, :what => :hp, :from => 100, :to => 90},
      {:who => :@monster_fight, :what => :character_damage, :from => nil, :to => 10},
      {:who => :@character, :what => :experience, :from => 0, :to => 1},
      {:who => :@monster_fight, :what => :experience, :from => nil, :to => 1},
      {:who => :@character, :what => :basic_money, :from => 0, :to => 5},
      {:who => :@monster_fight, :what => :money, :from => nil, :to => 5},
      {:who => :@character, :what => :sp, :from => 10, :to => 9},
      {:who => :@monster_fight, :what => :stamina, :from => nil, :to => 1},
      {:who => :@monster_fight, :what => :damage, :from => 0, :to => 20},
    ].each do |t|
      
      it "should change #{t[:who]} #{t[:what]} from #{t[:from]} to #{t[:to]}" do
        lambda {
          @monster_fight.attack!
        }.should change(instance_variable_get(t[:who]), t[:what]).from(t[:from]).to(t[:to])
      end
      
      from = t[:from].nil? ? 0 : t[:from]
      power_attack_diff = (t[:to] - from) * Setting.i(:monster_fight_power_attack_factor)
      power_attack_to = from + power_attack_diff
      
      it "power_attack should change #{t[:who]} #{t[:what]} from #{t[:from]} to #{power_attack_to}" do
        lambda {
          @monster_fight.attack!(true)
        }.should change(instance_variable_get(t[:who]), t[:what]).from(t[:from]).to(power_attack_to)
      end
    end
    
    it 'should save monster' do
      @monster_fight.attack!

      @monster.should_not be_changed
    end

    it 'should save character' do
      @monster_fight.attack!

      @character.should_not be_changed
    end
    
    describe 'when monster got defeated' do
      it 'should add news to character newsfeed about the victory' do
        @monster.should_receive(:won?).and_return(true)
        
        lambda{
          @monster_fight.attack!
        }.should change(@character.news, :count).by(1)
        
        @character.news.last.monster_fight.should == @monster_fight
      end
      
      it 'should save killer' do
        @monster.should_receive(:won?).and_return(true)
        @monster_fight.attack!
        @monster.killer.should == @character
      end
      
      it 'should updated stats for killer' do
        @monster.should_receive(:won?).and_return(true)
        @monster_fight.attack!
        @character.killed_monsters_count.should == 1
      end
      
      it 'should update stats for attacker and killer' do
        @monster.should_receive(:won?).and_return(true)
        
        @killer = Factory(:character)
        @killed_monster_fight = MonsterFight.create(:character => @killer, :monster => @monster)
        
        @killed_monster_fight.attack!
        
        @monster.character.killed_monsters_count.should == 1
        @killer.killed_monsters_count.should == 1
      end
    end

    it 'should be saved' do
      @monster_fight.attack!

      @monster_fight.should_not be_changed
    end

    it 'should return true' do
      @monster_fight.attack!.should be_true
    end
    
  end
  
  describe "when checking if player dealt significant damage to monster" do
    it 'should return true if user is in monsters_maximum_reward_collectors limit and false otherwise with default settings' do
      @monster = Factory(:monster)
      @monster_fight1 = Factory(:monster_fight, :monster => @monster)
      @monster_fight2 = Factory(:monster_fight, :monster => @monster)
      @monster_fight3 = Factory(:monster_fight, :monster => @monster)
      @monster_fight4 = Factory(:monster_fight, :monster => @monster)
      @monster_fight5 = Factory(:monster_fight, :monster => @monster)
      @monster_fight6 = Factory(:monster_fight, :monster => @monster)
      
      @monster_fight1.damage = 50
      @monster_fight2.damage = 50
      @monster_fight3.damage = 50
      @monster_fight4.damage = 50
      @monster_fight5.damage = 50
      @monster_fight6.damage = 40
      
      @monster_fight1.significant_damage?.should be_true
      @monster_fight2.significant_damage?.should be_true
      @monster_fight3.significant_damage?.should be_true
      @monster_fight4.significant_damage?.should be_true
      @monster_fight5.significant_damage?.should be_true
      
      @monster_fight6.significant_damage?.should be_false
    end
    
    it 'should return true if user is in monsters_maximum_reward_collectors limit and false otherwise with default settings' do
      @monster = Factory(:monster, :monster_type => Factory(:monster_type, :maximum_reward_collectors => 1))
      @monster_fight1 = Factory(:monster_fight, :monster => @monster)
      @monster_fight2 = Factory(:monster_fight, :monster => @monster)
      
      @monster_fight1.damage = 50
      
      @monster_fight1.significant_damage?.should be_true
      @monster_fight2.significant_damage?.should be_false
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
    
    it "should return false if player didn't done significant damage to monster" do
      @monster_fight.monster.win
      
      @monster_fight.should_receive(:significant_damage?).and_return(false)
      
      @monster_fight.reward_collectable?.should_not be_true
    end

    it 'should return false if monster is won and fight is not saved yet' do
      Monster.first.win

      @monster_fight = Factory.build(:monster_fight, :monster => Monster.first)

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


  describe '#repeat_fight?' do
    before do
      @monster_fight = Factory(:monster_fight)
    end

    it 'should return false if there is no collected rewards for fights with this monster type' do
      @monster_fight.repeat_fight?.should be_false
    end

    it 'should return false if there are no fights with this monster type and the fight is won' do
      @monster_fight.monster.win

      @monster_fight.repeat_fight?.should be_false
    end

    it 'should return false if there are won fights with this monster type but reward isn\'t collected' do
      @second_monster = Factory(:monster, :monster_type => @monster_fight.monster.monster_type)
      @second_monster_fight = Factory(:monster_fight, :character => @monster_fight.character, :monster => @second_monster)
      @second_monster.win

      @monster_fight.monster.win

      @monster_fight.repeat_fight?.should be_false
    end
    
    it 'should return true if there is a fight with this monster type and the reward for this fight is collected' do
      @second_monster = Factory(:monster, :monster_type => @monster_fight.monster.monster_type)
      @second_monster_fight = Factory(:monster_fight, :character => @monster_fight.character, :monster => @second_monster)
      @second_monster.win
      @second_monster_fight.collect_reward!.should be_true

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
  
  describe '#summoner?' do
    before do
      @character = Factory(:character)
      @monster = Factory(:monster, :character => @character)

      @monster_fight = MonsterFight.create(:monster => @monster, :character => @character)
    end
    
    it 'should return true if monster character equals to fight character' do
      @monster_fight.summoner?.should be_true
    end
    
    it 'should return false if monster character differs from fight character' do
      @monster_fight.character = Factory(:character)
      
      @monster_fight.summoner?.should be_false
    end
  end
end