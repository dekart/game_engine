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
  
  after_create :schedule_social_data_update

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
  
  def update_social_data!
    return false if access_token.blank? || access_token_expired?
    
    client = Mogli::Client.new(access_token)
    
    user = Mogli::User.find(facebook_id, client, :first_name, :last_name, :timezone, :locale, :gender, :third_party_id)
    
    %w{first_name last_name timezone locale third_party_id}.each do |attribute|
      self.send("#{attribute}=", user.send(attribute))
    end
    
    self.gender = GENDERS[user.gender.to_sym] if user.gender
    
    save!
  end
  
  def update_dashboard_counters!
    authenticator = Mogli::Authenticator.new(Facebooker2.app_id, Facebooker2.secret, Facebooker2.callback_url)
    
    client = Mogli::Client.new(authenticator.get_access_token_for_application)
    
    client.class.get('https://api.facebook.com/method/dashboard.setCount', 
      :query => client.default_params.merge(
        :uid    => facebook_id,
        :count  => Invitation.for_user(self).count
      )
    )
  end
  
  def access_token_expired?
    access_token_expire_at.nil? or access_token_expire_at < Time.now
  end
  
  def schedule_social_data_update
    Delayed::Job.enqueue Jobs::UserDataUpdate.new([id])
  end

  def schedule_counter_update
    Delayed::Job.enqueue Jobs::UserCounterUpdate.new([id])
  end
end
