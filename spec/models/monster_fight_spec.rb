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
    it 'should not be valid if character does not have enough stamina'
    it 'should not be valid if monster is not in the progress'

    describe 'when valid' do
      it 'should calculate damage dealt to monster and character'
      it 'should apply damage to monster'
      it 'should apply damage to character'
      it 'should apply experience reward to character'
      it 'should apply money reward to character'
      it 'should save monster'
      it 'should save character'
      it 'should mark monster as won if monster is dead'
      it 'should add damage dealt to monster'
      it 'should be saved'
    end
  end
end