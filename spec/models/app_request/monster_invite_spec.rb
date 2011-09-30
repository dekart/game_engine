require 'spec_helper'
require 'models/app_request/common'

describe AppRequest::MonsterInvite do
  describe '#monster' do
    before do
      @request = Factory(:app_request_monster_invite)
    end
    
    it 'should return monster by ID stored in data' do
      @request.monster.should == @request.data['target_type'].constantize.find(@request.data['target_id'])
    end
    
  end
  
  
  describe '#accept' do
    before do
      @receiver = Factory(:user_with_character)

      @request  = Factory(:app_request_monster_invite)
    end
    
    it_should_behave_like 'application request accept'
    
    it 'should join receiver to monster fight' do
      lambda{
        @request.accept
      }.should change(@receiver.character.monster_fights, :count).from(0).to(1)
      
      @receiver.character.monster_fights.first.monster.should == @request.monster
    end
    
    it 'should increment accepted invites count to sender' do
      monster_fight = @request.sender.monster_fights.by_monster(@request.monster).first
      
      lambda{
        @request.accept!
      }.should change{monster_fight.reload.accepted_invites_count}.by(1)
    end
  end
end