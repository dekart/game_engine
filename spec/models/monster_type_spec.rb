require 'spec_helper'

describe MonsterType do
  describe 'associations' do
    it 'should have many monsters' do
      should have_many :monsters
    end
  end
end