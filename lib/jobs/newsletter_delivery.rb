module Jobs
  class NewsletterDelivery < Struct.new(:newsletter_id)
    include Jobs::Common

    def perform
      return unless newsletter = Newsletter.find_by_id(newsletter_id)

      users = User.after(newsletter.last_recipient).all(
        :limit => Configuration[:newsletter_recipients_per_send]
      )
      
      if users.any?
        facebook_session.send_notification(users, newsletter.text)

        newsletter.update_attribute(:last_recipient, users.last)

        newsletter.delivery_job = Delayed::Job.enqueue(self.class.new(newsletter.id), 0, Configuration[:newsletter_send_sleep].seconds.from_now)
      else
        newsletter.finish_delivery!
      end
    end
  end
end