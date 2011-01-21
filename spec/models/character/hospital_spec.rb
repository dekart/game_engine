require 'spec_helper'

describe Character do
  describe 'when getting hospital healing price' do
    before do
      @character = Factory(:character)
    end
    
    it 'should use base price' do
      @character.hospital_price.should == 10
    end
    
    it 'should add price per point per level' do
      @character.hp -= 10
      
      @character.hospital_price.should == 35 # 10 + 2.5 * 10 points * level 1
      
      @character.level = 5
      
      @character.hospital_price.should == 135 # 10 + 2.5 * 10 points * level 5
    end
  end
end