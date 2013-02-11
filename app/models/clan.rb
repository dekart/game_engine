class Clan < ActiveRecord::Base
  has_many :characters, :through => :clan_members
  has_many :clan_members, :dependent => :destroy
  has_many :clan_membership_applications, :dependent => :destroy
  has_many :clan_membership_invitations, :dependent => :destroy

  validates_presence_of :name

  validates_uniqueness_of :name

  attr_accessible :name, :image, :description

  has_attached_file :image, :styles => { :medium => "200x200#", :small => "85x85#" }

  def members_facebook_ids
    clan_members.collect{|m| m.character.facebook_id}
  end

  def change_image!(params)
    if params
      if enough_vip_money?(creator, Setting.i(:clan_change_image_vip_money))
        transaction do
          update_attributes(params) && creator.charge!(0, Setting.i(:clan_change_image_vip_money), :clan_image)
        end
      end
    else
      errors.add(:image, :not_loaded_image)

      false
    end
  end

  def create_by!(character)
    if valid? && enough_vip_money?(character, Setting.i(:clan_create_for_vip_money))
      transaction do
        if save! && character.charge!(0, Setting.i(:clan_create_for_vip_money), :create_clan)
          character.clan_membership_applications.destroy_all

          clan_members.create(:character => character, :role => :creator)

          character.clan_membership_invitations.destroy_all
        end
      end
    end
  end

  def key_for_chat
    digest = Digest::MD5.hexdigest("%s-%s" % [id, created_at])

    "%s-%s" % [id, digest[0, 10]]
  end

  def creator
    clan_members.find_by_role('creator').try(:character)
  end

  def as_json(*args)
    {
      :name => name
    }
  end

  protected

  def enough_vip_money?(character, price)
    if character.vip_money >= price
      true
    else
      errors.add(:creator, :not_enough_vip_money)

      false
    end
  end
end
