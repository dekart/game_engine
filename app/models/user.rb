class User < ActiveRecord::Base
  has_one :character

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

  def initialize(*args)
    super

    self.create_character unless self.character

    logger.debug self.character
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
    ADMINS.include?(self.facebook_id)
  end

  def deliver_welcome_message!
    Delayed::Job.enqueue Jobs::WelcomeNotification.new(self.id)
  end
end
