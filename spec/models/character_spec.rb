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
end