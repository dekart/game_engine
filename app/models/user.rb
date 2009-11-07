class User < ActiveRecord::Base
  has_one :character, :dependent => :destroy

  has_many :invitations, :foreign_key => :sender_id do
    def facebook_ids
      self.find(:all, :select => "invitations.receiver_id").collect{|i| i[:receiver_id].to_i }
    end
  end

  named_scope :after, Proc.new{|user|
    {:conditions => ["id > ?", user.is_a?(User) ? user.id : user.to_i], :order => "id ASC"}
  }
  
  attr_accessible :show_next_steps

  after_create :setup_profile!, :update_profile!, :deliver_welcome_message!

  def skip_tutorial?
    !(Configuration[:user_tutorial_enabled] and !self[:skip_tutorial])
  end

  def setup_profile!
    Delayed::Job.enqueue Jobs::SetupProfile.new(self.id)
  end

  def update_profile!
    Delayed::Job.enqueue Jobs::UpdateProfile.new(self.id)
  end

  def customized?
    true
  end

  def touch!
    self.update_attribute(:updated_at, Time.now)
  end

  def admin?
    Configuration[:user_admins].split(/\s*,\s*/).include?(self.facebook_id.to_s)
  end

  def deliver_welcome_message!
    Delayed::Job.enqueue Jobs::WelcomeNotification.new(self.id)
  end

  def should_visit_invite_page?
    Configuration[:user_invite_page_redirect_enabled] and
      self.created_at < Configuration[:user_invite_page_first_visit_delay].hours.ago and
      (self.invite_page_visited_at.nil? or self.invite_page_visited_at < Configuration[:user_invite_page_recurrent_visit_delay].hours.ago)
  end

  def invite_page_visited!
    self.update_attribute(:invite_page_visited_at, Time.now)
  end

  def should_visit_gift_page?
    Configuration[:gifting_enabled] and
      self.created_at < Configuration[:gifting_page_first_visit_delay].hours.ago and
      (self.gift_page_visited_at.nil? or self.gift_page_visited_at < Configuration[:gifting_page_recurrent_visit_delay].hours.ago)
  end

  def gift_page_visited!
    self.update_attribute(:gift_page_visited_at, Time.now)
  end
end
