class Newsletter < ActiveRecord::Base
  belongs_to :last_recipient, :class_name => "User"
  belongs_to :delivery_job, :class_name => "Delayed::Job", :dependent => :destroy

  state_machine :initial => :draft do
    state :draft
    state :delivering
    state :paused
    state :delivered

    event :start_delivery do
      transition [:draft, :paused, :delivered] => :delivering
    end

    event :finish_delivery do
      transition :delivering => :delivered
    end

    event :pause_delivery do
      transition :delivering => :paused
    end

    after_transition any => :delivering do |newsletter|
      newsletter.schedule_delivery
    end

    after_transition :delivering => any do |newsletter|
      newsletter.delivery_job.try(:destroy)
    end
  end

  validates_presence_of :text

  def schedule_delivery(time = nil)
    self.delivery_job = Delayed::Job.enqueue(Jobs::NewsletterDelivery.new(id), 0, time || Time.now)
  end
end
