class AppRequest::MonsterInvite < AppRequest::Base
  def monster
    target
  end
  
  protected
  
  def after_accept
    super
    
    MonsterFight.create(:character => receiver, :monster => monster)
  end
end