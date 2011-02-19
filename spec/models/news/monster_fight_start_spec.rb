require 'spec_helper'

describe News::MonsterFightStart do
  it 'should delegate monster to monster figth' do
    @monster_fight = Factory(:monster_fight)
    @news = News::MonsterFightStart.create(:data => {:monster_fight_id => @monster_fight.id})
    
    @news.monster.should === @monster_fight.monster
  end
  
  describe '#monster_fight' do
    before do
      @monster_fight = Factory(:monster_fight)
      
      @news = News::MonsterFightStart.create(:data => {:monster_fight_id => @monster_fight.id})
    end
    
    it 'should return monster fight from data' do
      @news.monster_fight.should == @monster_fight
    end
  end
end