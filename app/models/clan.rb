class Clan < ActiveRecord::Base
  has_many :characters, :through => :clan_members
  has_many :clan_members, :dependent => :destroy
  
  validates_presence_of :name
  
  attr_accessible :name, :image

  has_attached_file :image, :styles => { :small => "200x200" }
  
  def is_member?(character)
    clan_members.detect{|m| m.character_id == character.id}
  end
  
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
