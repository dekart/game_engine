require 'spec_helper'

describe Character::FriendFilter do
  before do
    @non_player_facebook_id = 444 
    
    @character1 = Factory(:character, :user => Factory(:user, :facebook_id => 1, :friend_ids => "2,3,4,#{@non_player_facebook_id}"))
    @character2 = Factory(:character, :user => Factory(:user, :facebook_id => 2, :friend_ids => "1"))
    @character3 = Factory(:character, :user => Factory(:user, :facebook_id => 3, :friend_ids => "1"))
    
    @character4 = Factory(:character, :user => Factory(:user, :facebook_id => 4))
    @request  = Factory(:app_request_invitation, :state => 'processed', :receiver_id => @character4.user.facebook_id, :sender => @character1)
    
    @character5 = Factory(:character, :user => Factory(:user, :facebook_id => 5))
    
    @character1.friend_relations.establish!(@character2)
  end
  
  it 'should return invited_recently users' do
    @character1.friend_filter.invited_recently.should == [@character4.user.facebook_id]
  end
  
  it 'should return all users' do
    @character1.friend_filter.all.should include(
      @character2.user.facebook_id, @character3.user.facebook_id, @character4.user.facebook_id, @non_player_facebook_id
    )
  end
  
  it 'should return users that exists in application' do
    @character1.friend_filter.app_users.should include(
      @character2.user.facebook_id, @character3.user.facebook_id, @character4.user.facebook_id
    )
  end
  
  it 'should return users in friend relation' do
    @character1.friend_filter.in_relation.should == [@character2.user.facebook_id]
  end
   
  it 'should return facebook users for invitation' do
    @character1.friend_filter.for_invitation.should == [@character3.user.facebook_id, @non_player_facebook_id]
  end
  
  it 'should not return facebook user for invitations if friend relationship between characters exists' do
    @character2.friend_filter.for_invitation.should be_empty
  end
  
  it 'should not return facebook users for invitation for character without facebook friends' do
    @character5.friend_filter.for_invitation.should be_empty
  end
  
  it 'should limit facebook users for invitation' do
    @character1.friend_filter.for_invitation(1).should == [@character3.user.facebook_id]
  end
end