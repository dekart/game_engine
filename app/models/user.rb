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
    return false if access_token.blank?
    
    client = Mogli::Client.new(access_token)
    user = Mogli::User.new(:id => facebook_id)
    user.client = client
    user.fetch
    
    %w{first_name last_name timezone locale}.each do |attribute|
      self.send("#{attribute}=", user.send(attribute))
    end
    
    self.gender = GENDERS[user.gender.to_sym]
    
    save!
  end
  
  protected
  
  def schedule_social_data_update
    Delayed::Job.enqueue Jobs::UserDataUpdate.new([id])
  end
end
