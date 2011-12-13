class ClanMember < ActiveRecord::Base
  ROLE = {:creator => "creator", :participant => "participant"}
  
  belongs_to :clan, :counter_cache => :members_count
  belongs_to :character
  
  before_create :role_assignment
  
  def creator?
    role == ROLE[:creator]
  end
  
  protected
  
  def role_assignment
    self.role = ROLE[role]
  end
  
end