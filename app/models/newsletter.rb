class Newsletter < ActiveRecord::Base
  belongs_to :last_recipient, :class_name => "User"
  belongs_to :delivery_job, :class_name => "Delayed::Job", :dependent => :destroy

  include Workflow

  workflow do
    state :draft do
      event :deliver!, :transitions_to => :delivering
    end

    state :delivering do
      event :pause!,      :transitions_to => :draft
      event :delivered!,  :transitions_to => :delivered
    end

    state :delivered
  end

  validates_presence_of :text

  def start_delivery!
    return unless self.draft?

    self.class.transaction do
      self.deliver!
      self.delivery_job = Delayed::Job.enqueue(Jobs::NewsletterDelivery.new(self.id))

      self.save!
    end
  end

  def pause_delivery!
    return unless self.delivering?

    self.class.transaction do
      self.pause!
      self.delivery_job.destroy if self.delivery_job

      self.save!
    end
  end

  def finish_delivery!
    return unless self.delivering?

    self.class.transaction do
      self.delivered!
      self.save!
    end
  end
end
