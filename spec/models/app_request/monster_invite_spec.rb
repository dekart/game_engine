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
end