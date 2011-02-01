require 'spec_helper'

describe Character do
  describe 'associations' do
    before do
      @character = Character.new
    end
    
    it 'should have many vip money deposits' do
      @character.should have_many(:vip_money_deposits).dependent(:destroy)
    end
    
    it 'should have many vip money withdrawals' do
      @character.should have_many(:vip_money_withdrawals).dependent(:destroy)
    end
  end
  
  describe 'when updating' do
    before do
      @character = Factory(:character)
    end
    
    it 'should assign fight availablity time when health point level is changed' do
      lambda{
        @character.save!
      }.should_not change(@character, :fighting_available_at)
      
      Timecop.freeze(Time.now) do
        @character.hp = 0

        lambda{
          @character.save!
        }.should change(@character, :fighting_available_at).to(5.minutes.from_now)
      end
    end
  end
  
  describe 'when fetching a list of possible fight opponents' do
    before do
      @character = Factory(:character)
    end
    
    it 'should scope opponents to a passed scope'
    it 'should not include recent opponents to the list'
    it 'should not include alliance members to the list if configured that way'
    it 'should not include self to the list'
    it 'should not include opponents from higher and lower levels'
    
    it 'should not include weak opponents if configured that way' do
      @opponent = Factory(:character)
      
      @character.possible_victims.should include(@opponent)
      
      @opponent.hp = 0
      @opponent.save!
            
      @character.possible_victims.should include(@opponent)
      
      with_setting(:fight_weak_opponents, false) do
        @character.possible_victims.should_not include(@opponent)
      end
    end
    
    it 'should choose opponents with closest level'
    it 'should limit list to 10 opponents'
    it 'should randomize opponent list'
  end

  describe 'when checking whether can attack an opponent' do
    before do
      @character  = Factory(:character)
      @opponent   = Factory(:character)
    end
    
    it 'should return false if opponent level is too low'
    it 'should return false if opponent level is too high'
    it 'should return false if attacked this opponent recently'
    it 'should return false when attacking alliance member (if configured that way)'
    
    it 'should return false when attacking weak opponent (if configured that way)' do
      @opponent.hp = 0
      @opponent.save!
      
      @character.can_attack?(@opponent).should be_true
      
      with_setting(:fight_weak_opponents, false) do
        @character.can_attack?(@opponent).should be_false
      end
    end
    
    it 'should return true if all requirements are met' do
      @character.can_attack?(@opponent).should be_true
    end
  end
end