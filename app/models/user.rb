class User < ActiveRecord::Base
  GENDERS = {:male => 1, :female => 2}
  
  has_one     :character, :dependent => :destroy
  belongs_to  :referrer, :class_name => "User"

  named_scope :latest, {
    :order    => 'users.created_at DESC',
    :include  => :character,
    :limit    => 50
  }
  named_scope :after, Proc.new{|user|
    {
      :conditions => ["`users`.id > ?", user.is_a?(User) ? user.id : user.to_i],
      :order      => "`users`.id ASC"
    }
  }
  
  named_scope :with_email, {:conditions => "email != ''"}
  
  after_save :schedule_social_data_update,  :if => :access_token_changed?
  after_save :generate_personal_discount,   :if => :last_visit_at_changed?
  
  before_create :set_first_tutorial_step
  
  def show_tutorial?
    Setting.b(:user_tutorial_enabled) && self[:show_tutorial]
  end

  def customized?
    true
  end

  def touch!
    update_attribute(:updated_at, Time.now)
  end

  def admin?
    Setting.a(:user_admins).include?(facebook_id.to_s)
  end
  
  def last_visit_ip=(value)
    self[:last_visit_ip] = value.is_a?(String) ? IPAddr.new(value).to_i : value
  end
  
  def last_visit_ip
    IPAddr.new(self[:last_visit_ip], Socket::AF_INET) if self[:last_visit_ip]
  end
  
  def signup_ip=(value)
    self[:signup_ip] = value.is_a?(String) ? IPAddr.new(value).to_i : value
  end
  
  def signup_ip
    IPAddr.new(self[:signup_ip], Socket::AF_INET) if self[:signup_ip]
  end
  
  def friend_ids=(values)
    self[:friend_ids] = Array.wrap(values).join(',')
  end
  
  def friend_ids
    self[:friend_ids].blank? ? [] : self[:friend_ids].split(',').collect{|i| i.to_i }
  end
  
  def friends_with?(player)
    friend_ids.include?(player.facebook_id)
  end
  
  def facebook_client
    Koala::Facebook::API.new(access_token)
  end
  
  def update_social_data!
    return false unless access_token_valid?
    
    me, friends = facebook_client.batch do |api|
      api.get_object('me', :fields => [:first_name, :last_name, :timezone, :locale, :gender, :third_party_id, :email].join(','))
      api.get_connections('me', 'friends', :fields => 'id')
    end
    
    self.attributes = me
    self.friend_ids = friends.collect{|f| f["id"] }
    
    save!
  end
  
  def gender=(value)
    if value.blank?
      self[:gender] = nil
    elsif GENDERS[value.to_sym]
      self[:gender] = GENDERS[value.to_sym]
    else
      raise ArgumentError.new("Only #{ GENDERS.keys.join(' and ') } values are allowed")
    end
  end
  
  def gender
    GENDERS.index(self[:gender]) || :unknown
  end
  
  def full_name
    [first_name, last_name].join(' ')
  end
  
  def anonymous_id
    third_party_id.present? ? third_party_id : id
  end
  
  def access_token_valid?
    !(access_token.blank? || access_token_expire_at.nil? || access_token_expire_at < Time.now)
  end
  
  def permissions
    if access_token_valid?
      Koala::Facebook::API.new(access_token).get_connections(:me, :permissions).first.keys.map{|k| k.to_sym }
    else
      []
    end
  end
  
  def schedule_social_data_update
    Delayed::Job.enqueue Jobs::UserDataUpdate.new([id]) if access_token_valid?
  end
  
  def generate_personal_discount
    character.personal_discounts.generate_if_possible! if character.respond_to?(:personal_discounts)
  end
  
  def set_first_tutorial_step
    self.tutorial_step = Tutorial.first_step
  end
end
