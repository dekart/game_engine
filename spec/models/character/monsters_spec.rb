require "spec_helper"

describe Character do
  describe 'when fetching monster types available for fight' do
    before do
      @monster_type1 = Factory(:monster_type)
      @monster_type2 = Factory(:monster_type, :level => 2)
      @monster_type3 = Factory(:monster_type, :level => 3)

      @character = Factory(:character, :level => 2)
    end
    
    it 'should fetch all monsters with level lower than character\'s level' do
      @character.monster_types.available_for_fight.should include(@monster_type1, @monster_type2)
      @character.monster_types.available_for_fight.should_not include(@monster_type3)
    end

    it 'should exclude monsters which are currently active' do
      Monster.create!(:character => @character, :monster_type => @monster_type1)

      @character.monster_types.available_for_fight.should_not include(@monster_type1)
    end
    
    it 'should fetch next available monsters' do
      @character.monster_types.available_in_future.should include(@monster_type3)
      @character.monster_types.available_in_future.should_not include(@monster_type1, @monster_type2)
    end
  end
  
  describe '#payout_triggers' do
    before do
      @character = Factory(:character)
      @monster_type = Factory(:monster_type)
    end

    it 'should return :victory if there are no collected rewards for this monster type' do
      @character.monster_types.payout_triggers(@monster_type).should == [:victory]
    end

    it 'should return :repeat_victory if character already collected reward from this monster type' do
      @character.monster_types.collected.should_receive(:ids).and_return([@monster_type.id])
      
      @character.monster_types.payout_triggers(@monster_type).should == [:repeat_victory]
    end
  end
end