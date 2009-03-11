class User < ActiveRecord::Base
  has_one :character

  attr_accessible :show_next_steps

  after_create :setup_profile!, :update_profile!

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
end
