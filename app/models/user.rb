class User < ActiveRecord::Base
  attr_accessible :show_next_steps

  after_create :setup_profile!, :update_profile!

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
end
