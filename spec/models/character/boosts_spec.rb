require 'spec_helper'

describe Character::Boosts do
  before do
    @fight_attack_item_boost = Factory(:item, 
      :boost_type => 'fight',
      :effects => [
        {:type => :attack, :value => 1}, 
        {:type => :defence, :value => 0}
      ]
    )

    @fight_defence_item_boost = Factory(:item, 
      :boost_type => 'fight', 
      :effects => [
        {:type => :attack, :value => 0}, 
        {:type => :defence, :value => 1}
      ]
    )
    
    @monster_attack_item_boost = Factory(:item, 
      :boost_type => 'monster', 
      :effects => [
        {:type => :damage, :value => 1}, 
        {:type => :attack, :value => 0}, 
        {:type => :defence, :value => 0}
      ]
    )
    
    @character = Factory(:character)
  end
  
  describe 'inventories' do
    it 'should select one fight boost from inventories' do
      @character.inventories.give!(@fight_attack_item_boost)
      
      @character.boosts.by_type('fight').first.item.should == @fight_attack_item_boost
    end
    
    it 'should select two fight boosts from inventories' do
      @character.inventories.give!(@fight_attack_item_boost)
      @character.inventories.give!(@fight_defence_item_boost)
      
      @character.boosts.by_type('fight').size.should == 2
    end
    
    it 'should have monster boost on inventories' do
      @character.inventories.give!(@monster_attack_item_boost)
      
      @character.boosts.by_type('monster').first.item.should == @monster_attack_item_boost
    end
    
    it 'should not select boosts inappropriate type' do
      @character.inventories.give!(@fight_attack_item_boost)
      @character.inventories.give!(@monster_attack_item_boost)
      
      @character.boosts.by_type('fight').first.item.should == @fight_attack_item_boost
      @character.boosts.by_type('monster').first.item.should == @monster_attack_item_boost
    end
    
    it 'should select boosts from inventories for fight attack' do
      @character.inventories.give!(@fight_attack_item_boost)
      
      @character.boosts.for(:fight, :attack).first.item.should == @fight_attack_item_boost
      @character.boosts.for(:fight, :defence).should be_empty
      @character.boosts.for(:monster, :attack).should be_empty
    end
    
    it 'should select boosts from inventories for fight defence' do
      @character.inventories.give!(@fight_defence_item_boost)
      
      @fight_defence_item_boost.effect(:defence).should == 1
      
      @character.boosts.for(:fight, :defence).first.item.should == @fight_defence_item_boost
      @character.boosts.for(:fight, :attack).should be_empty
      @character.boosts.for(:monster, :attack).should be_empty
    end
    
    it 'should select boosts from inventories for monster attack' do
      @character.inventories.give!(@monster_attack_item_boost)
      
      @character.boosts.for(:monster, :attack).first.item.should == @monster_attack_item_boost
      @character.boosts.for(:fight, :attack).should be_empty
      @character.boosts.for(:fight, :defence).should be_empty
    end
  end
  
  describe 'active' do
    before do
      @fight_attack_boost = @character.inventories.give!(@fight_attack_item_boost)
      @fight_defence_boost = @character.inventories.give!(@fight_defence_item_boost)
      @monster_attack_boost = @character.inventories.give!(@monster_attack_item_boost)
    end
    
    it 'should have active fight boost' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {'fight' => {'attack' => @fight_attack_item_boost.id}}
    end
    
    it 'should have active defence boost' do
      @character.activate_boost!(@fight_defence_item_boost, 'defence')
      
      @character.active_boosts.should == {'fight' => {'defence' => @fight_defence_item_boost.id}}
    end
    
    it 'should deactivate fight boost' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      @character.deactivate_boost!(@fight_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {'fight' => {}}
    end
    
    it 'should have active boost after toggle' do
      @character.toggle_boost!(@fight_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {'fight' => {'attack' => @fight_attack_item_boost.id}}
    end
    
    it 'should dont have active boost after double toggling' do
      @character.toggle_boost!(@fight_attack_item_boost, 'attack')
      @character.toggle_boost!(@fight_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {'fight' => {}}
    end
    
    it 'should have two active boosts different types' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      @character.activate_boost!(@fight_defence_item_boost, 'defence')
      
      @character.active_boosts.should == {'fight' => {'attack' => @fight_attack_item_boost.id, 'defence' => @fight_defence_item_boost.id}}
    end
    
    it 'should not have more than one active same type boosts' do
      another_attack_item_boost = Factory(:item, 
        :boost_type => 'fight',
        :effects => [
          {:type => :attack, :value => 1}, 
          {:type => :defence, :value => 0}
        ]
      )
      another_attack_boost = @character.inventories.give!(another_attack_item_boost)
      
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      @character.activate_boost!(another_attack_item_boost, 'attack')
      
      @character.boosts.active_for(:fight, :attack).should == another_attack_boost
    end
    
    it 'should select boosts for monster attack' do
      @character.activate_boost!(@monster_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {'monster' => {'attack' => @monster_attack_item_boost.id}}
    end
    
    it 'should activate all type of boosts' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      @character.activate_boost!(@fight_defence_item_boost, 'defence')
      @character.activate_boost!(@monster_attack_item_boost, 'attack')
      
      @character.active_boosts.should == {
        'fight' => {'attack' => @fight_attack_item_boost.id, 'defence' => @fight_defence_item_boost.id}, 
        'monster' => {'attack' => @monster_attack_item_boost.id}
      }
    end
    
    it 'should select active boost for fight attack' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      
      @character.boosts.active_for(:fight, :attack).should == @fight_attack_boost
      @character.boosts.active_for(:fight, :defence).should be_nil
      @character.boosts.active_for(:monster, :attack).should be_nil
    end
    
    it 'should select active boost for fight defence' do
      @character.activate_boost!(@fight_defence_item_boost, 'defence')
      
      @character.boosts.active_for(:fight, :defence).should == @fight_defence_boost
      @character.boosts.active_for(:fight, :attack).should be_nil
      @character.boosts.active_for(:monster, :attack).should be_nil
    end
    
    it 'should select active boost for monster attack' do
      @character.activate_boost!(@monster_attack_item_boost, 'attack')
      
      @character.boosts.active_for(:monster, :attack).should == @monster_attack_boost
      @character.boosts.active_for(:fight, :defence).should be_nil
      @character.boosts.active_for(:fight, :attack).should be_nil
    end
    
    it 'should not select active boost if he dont exists in inventories' do
      @character.activate_boost!(@fight_attack_item_boost, 'attack')
      @character.inventories.take!(@fight_attack_item_boost)
      
      @character.boosts.active_for(:fight, :attack).should be_nil
    end
  end
  
end