require 'spec_helper'

describe Fight do
  describe '#attacker_level_range' do
    before do
      @attacker = Factory(:character)

      @fight = Fight.new(:attacker => @attacker)
    end

    [1, 2, 3, 4, 5, 7, 11, 20, 30, 75, 120].each do |level|
      describe "on level #{level}" do
        before do
          @attacker.level = level
        end
        
        it "should return level range for level #{level}" do
          @fight.attacker_level_range.should be_kind_of(Range)
        end
      
        it 'should return range that includes attacker level' do
          @fight.attacker_level_range.should include(level)
        end
      end
    end
  end
  
  
  describe '#can_attack?' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
    end
    
    it 'should return false if defeated this opponent less than 1 hour ago' do
      Fight.create!(:attacker => @attacker, :victim => @victim)
      
      Fight.last.update_attribute(:winner_id, @victim.id)      
            
      @fight.can_attack?.should be_true
      
      Fight.last.update_attribute(:winner_id, @attacker.id)
      
      @fight.can_attack?.should be_false

      Fight.last.update_attribute(:created_at, 61.minute.ago)

      @fight.can_attack?.should be_true
    end
    
    it 'should return false when attacking alliance member (if configured that way)' do
      @attacker.friend_relations.establish!(@victim)
      
      @fight.can_attack?.should be_true
      
      with_setting(:fight_alliance_attack => false) do
        @fight.can_attack?.should be_false
      end
    end
    
    it 'should return false when attacking weak opponent (if configured that way)' do
      @victim.hp = 0
      @victim.save!
      
      @fight.can_attack?.should be_true
      
      with_setting(:fight_weak_opponents => false) do
        @fight.can_attack?.should be_false
      end
    end
    
    it 'should return true if all requirements are met' do
      @fight.can_attack?.should be_true
    end
  end
  
  
  describe '#opponents' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @fight = Fight.new(:attacker => @attacker)
    end
        
    it 'should not include victims defeated less than 1 hour ago' do
      Fight.create!(:attacker => @attacker, :victim => @victim)
      
      Fight.last.update_attribute(:winner_id, @victim.id)      
            
      @fight.opponents.should include(@victim)
      
      Fight.last.update_attribute(:winner_id, @attacker.id)
      
      @fight.opponents.should_not include(@victim)
      
      Fight.last.update_attribute(:created_at, 61.minute.ago)
      
      @fight.opponents.should include(@victim)
    end
    
    it 'should not include alliance members to the list (if configured that way)' do
      @attacker.friend_relations.establish!(@victim)

      @fight.opponents.should include(@victim)

      with_setting(:fight_alliance_attack => false) do
        @fight.opponents.should_not include(@victim)
      end
    end
    
    it 'should not include attacker to the list' do
      @fight.opponents.should_not include(@attacker)
    end
    
    it 'should not include weak opponents if configured that way' do
      @fight.opponents.should include(@victim)
      
      @victim.hp = 0
      @victim.save!
            
      @fight.opponents.should include(@victim)
      
      with_setting(:fight_weak_opponents => false) do
        @fight.opponents.should_not include(@victim)
      end
    end
    
    it 'should limit list to 10 opponents' do
      10.times do
        Factory(:character)
      end
      
      @fight.opponents.size.should == 10
    end
    
    it 'should randomize opponents' do
      10.times do
        Factory(:character)
      end
      
      @fight.opponents.should_not == @fight.opponents
    end
  end


  describe 'when creating' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
      
      @payout = Factory(:global_payout,
        :alias => 'fights',
        :payouts => Payouts::Collection.new(
          DummyPayout.new(:apply_on => :success, :name => 'success'), 
          DummyPayout.new(:apply_on => :failure, :name => 'failure')
        )
      )
      
      @payout.publish!
    end
    
    it 'should give an error when attacker doesn\'t have enough stamina'
    
    it 'should give an error when victim is too weak (if configured that way)' do
      @victim.hp = 0
      @victim.save!
      
      @fight.should be_valid
      
      with_setting(:fight_weak_opponents => false) do
        @fight.should_not be_valid
        @fight.errors.on(:victim).should =~ /too weak/
      end
    end
    
    it 'should decrease victim hp if victim visited game less then 1 hour ago' do
      @victim.user.last_visit_at = Time.now
      @victim.user.save!
      
      @fight.stub!(:calculate_damage).and_return([2, 0])
      
      with_setting(:fight_victim_hp_decrease_if_character_was_online => 1) do
        lambda {
          @fight.save! 
        }.should change(@victim, :hp).by(-2)
      end
    end
    
    describe 'if victim visited the game more than 1 hour ago' do
      before do
        @victim.user.last_visit_at = 2.hours.ago
        @victim.user.save!
      
        @fight.stub!(:calculate_damage).and_return([2, 0])
      end
      
      it 'should not decrease victim hp' do
        with_setting(:fight_victim_hp_decrease_if_character_was_online => 1) do
          lambda {
            @fight.save! 
          }.should_not change(@victim, :hp)
        end
      end
    
      it 'should decrease victim hp if fight has a cause' do
        @other_fight = Fight.create(:attacker => @victim, :victim => @attacker, :winner => @victim)
        @fight.cause = @other_fight
        
        with_setting(:fight_victim_hp_decrease_if_character_was_online => 1) do
          lambda {
            @fight.save! 
          }.should change(@victim, :hp).by(-2)
        end
      end
    end
    
    it 'should give an error when attacking alliance member if configured that way'
    it 'should give an error when attacker is weak'
    it 'should give an error when trying to attack yourself'
    it 'should give an error when trying to respond to fight that is not respondable'
    it 'should give an error when trying to attack a victim that attacker cannot attack'
    
    it 'should be successfully created' do
      @fight.save.should be_true
    end
    
    describe 'when won the fight' do
      before do
        @fight.stub!(:attacker_won?).and_return(true)
      end
      
      it 'should apply global :success payout' do        
        @fight.save
        
        @fight.payouts.should be_kind_of(Payouts::Collection)
        @fight.payouts.size.should == 1
        @fight.payouts.first.should be_applied
        @fight.payouts.first.name.should == 'success'
      end
    end
    
    describe 'when lost the fight' do
      before do
        @fight.stub!(:attacker_won?).and_return(false)
      end

      it 'should apply global :success payout' do        
        @fight.save
        
        @fight.payouts.should be_kind_of(Payouts::Collection)
        @fight.payouts.size.should == 1
        @fight.payouts.first.should be_applied
        @fight.payouts.first.name.should == 'failure'
      end
    end
  end
  
  describe '#attacker_won?' do
    before do
      @attacker = Factory(:character)
      @victim   = Factory(:character)
      
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
    end
    
    it 'should calculate attacker victory' do
      @fight.should_receive(:calculate_attacker_victory).and_return(true)
      
      @fight.attacker_won?.should be_true
    end
    
    it 'should not re-calculate attacker victory if calculated once' do
      @fight.should_receive(:calculate_attacker_victory).once.and_return(false)
      
      @fight.attacker_won?.should be_false
    end
    
    describe 'when winner is already set' do
      it 'should return true if winner is attacker' do
        @fight.should_not_receive(:calculate_attacker_victory)

        @fight.winner = @attacker
        @fight.attacker_won?.should be_true
      end

      it 'should return false if winner is victim' do
        @fight.should_not_receive(:calculate_attacker_victory)

        @fight.winner = @victim
        @fight.attacker_won?.should be_false
      end
    end
  end

  describe 'boost effects' do
    before do
      @attacker = Factory(:character)
      @victim = Factory(:character)
      @fight = Fight.new(:attacker => @attacker, :victim => @victim)
      
      fight_attack_item_boost = Factory(:item, 
        :boost_type => 'fight',
        :effects => [
          {:type => :attack, :value => 1}, 
          {:type => :defence, :value => 0}
        ]
      )
      fight_defence_item_boost = Factory(:item, 
        :boost_type => 'fight',
        :effects => [
          {:type => :attack, :value => 0}, 
          {:type => :defence, :value => 1}
        ]
      )
      
      @fight_attack_boost = @attacker.inventories.give!(fight_attack_item_boost)
      @fight_defence_boost = @victim.inventories.give!(fight_defence_item_boost)
    end
    
    it 'should increase attack points' do
        lambda {
          @attacker.activate_boost!(@fight_attack_boost, 'attack')
        }.should change(@attacker, :attack_points).by(1)
      end
      
      it 'should increase defence points' do
        lambda {
          @victim.activate_boost!(@fight_defence_boost, 'defence')
        }.should change(@victim, :defence_points).by(1)
      end
    
    it 'should take fight attack boost if it is active' do
      @attacker.activate_boost!(@fight_attack_boost, 'attack')
      
      lambda {
        @fight.save!
      }.should change {@attacker.boosts.inventories.count}.by(-1)
    end

    it 'should not take fight attack boost if it is not active' do
      lambda {
        @fight.save!
      }.should_not change {@attacker.boosts.inventories.count}
    end
    
    it 'should take fight defence boost if it is active' do
      @victim.activate_boost!(@fight_defence_boost, 'defence')
      
      lambda {
        @fight.save!
      }.should change {@victim.boosts.inventories.count}.by(-1)
    end
    
    it 'should not take fight defence boost if it is not active' do
      lambda {
        @fight.save!
      }.should_not change {@victim.boosts.inventories.count}
    end
  end
end