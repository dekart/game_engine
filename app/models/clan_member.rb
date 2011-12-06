class ClanMember < ActiveRecord::Base
  ROLE = {:creator => "creator"}
  
  belongs_to :clan
  belongs_to :character
  
  before_create :role_assignment
  
  protected
  
  def role_assignment
    self.role = ROLE[role]
  end
  
end