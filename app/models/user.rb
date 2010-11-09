class User < ActiveRecord::Base
  PERMISSIONS = [:email]

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

  def permissions
    PERMISSIONS.select{|p| self["permission_#{p}"] }.collect{|p| p.to_sym }
  end

  def clear_permissions
    PERMISSIONS.each do |permission|
      self["permission_#{permission}"] = false
    end
  end

  def add_permissions(values)
    permissions = PERMISSIONS & values.to_s.split(",").collect{|p| p.to_sym }

    permissions.each do |value|
      self["permission_#{value}"] = true
    end
  end

  def update_permissions!(values)
    clear_permissions

    add_permissions(values)

    save!
  end

  def should_request_permissions?
    if Setting.i(:user_permission_request_delay) == 0
      false
    elsif created_at > Setting.i(:user_permission_request_delay).hours.ago
      false
    elsif permissions_requested_at.nil? or permissions_requested_at < Setting.i(:user_permission_request_delay).hours.ago
      true
    else
      false
    end
  end
end
