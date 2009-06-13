class Jobs::NewsletterDelivery < Struct.new(:newsletter_id)
  include Common

  def perform
    return unless newsletter = Newsletter.find_by_id(newsletter_id)

    if users = User.after(newsletter.last_recipient).find(:all, :limit => 10) and users.any?
      facebook_session.send_notification(users, newsletter.text)

      newsletter.update_attribute(:last_recipient, users.last)

      newsletter.delivery_job = Delayed::Job.enqueue(self.class.new(newsletter.id), 0, 1.minute.from_now)
    else
      newsletter.finish_delivery!
    end
  end
end

