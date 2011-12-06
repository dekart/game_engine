class Clan < ActiveRecord::Base
  has_many :characters, :through => :clan_members
  has_many :clan_members 
  
  validates_presence_of :name
  
  def create_by!(character)
    if valid? && enough_vip_money?(character)
      transaction do
        if save! && character.charge!(0, Setting.i(:clan_create_for_vip_money))
          clan_members.create(:character => character, :role => :creator)
          
          true
        else
          false
        end
      end
      
    else
      false
    end
  end
  
  def enough_vip_money?(character)
    if character.vip_money >= Setting.i(:clan_create_for_vip_money)
      true
    else  
      errors.add(:character, :not_enough_vip_money)
      
      false
    end
  end
end
