class User < ActiveRecord::Base
  GENDERS = {:male => 1, :female => 2}
  
  has_one     :character, :dependent => :destroy
  belongs_to  :referrer, :class_name => "User"
  has_many    :invitations,
    :foreign_key  => :sender_id,
    :dependent    => :destroy,
    :extend       => User::Invitations

  named_scope :after, Proc.new{|user|
    {
      :conditions => ["id > ?", user.is_a?(User) ? user.id : user.to_i],
      :order      => "id ASC"
    }
  }

  attr_accessible :show_next_steps
  
  after_save :schedule_social_data_update, :if => :access_token_changed?

  def show_tutorial?
    Setting.b(:user_tutorial_enabled) && self[:show_tutorial]
  end

  def customized?
    true
  end

  def touch!
    update_attribute(:updated_at, Time.now)
  end

  def should_visit_landing_page?
    (landing_visited_at || created_at) < Setting.i(:landing_pages_visit_delay).hours.ago
  end

  def visit_landing!(name)
    self.landing_visited_at = Time.now
    self.last_landing = name.to_s

    save
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
  
  def update_social_data!
    return false unless access_token_valid?
    
    client = Mogli::Client.new(access_token)
    
    facebook_user = Mogli::User.find(facebook_id, client, :first_name, :last_name, :timezone, :locale, :gender, :third_party_id)
    
    %w{first_name last_name timezone locale third_party_id}.each do |attribute|
      self.send("#{attribute}=", facebook_user.send(attribute))
    end
    
    self.gender = GENDERS[facebook_user.gender.to_sym] if facebook_user.gender
    
    self.friend_ids = facebook_user.friends(:id).collect{|f| f.id }
    
    save!
  end
  
  def update_dashboard_counters!
    client = Mogli::Client.create_and_authenticate_as_application(Facebooker2.app_id, Facebooker2.secret)
    
    client.class.get('https://api.facebook.com/method/dashboard.setCount', 
      :query => client.default_params.merge(
        :uid    => facebook_id,
        :count  => Invitation.for_user(self).count
      )
    )
  end
  
  def access_token_valid?
    !(access_token.blank? || access_token_expire_at.nil? || access_token_expire_at < Time.now)
  end
  
  def schedule_social_data_update
    Delayed::Job.enqueue Jobs::UserDataUpdate.new([id]) if access_token_valid?
  end

  def schedule_counter_update
    Delayed::Job.enqueue Jobs::UserCounterUpdate.new([id])
  end
end
