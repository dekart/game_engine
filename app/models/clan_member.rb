class ClanMember < ActiveRecord::Base
  ROLE = {:creator => "creator"}
  
  belongs_to :clan
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