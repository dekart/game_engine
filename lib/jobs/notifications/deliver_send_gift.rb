module Jobs
  module Notifications
    class DeliverSendGift
      def perform
        Setting[:notifications_send_gift_displayed_at] = Time.now

        total = Character.count

        puts "Scheduling gifting notifications for #{total} characters..."

        i = 0

        Character.find_each(:batch_size => 1) do |character|
          character.notifications.schedule(:send_gift)

          i += 1

          puts "Processed #{i} of #{total}..." if i % 100 == 0
        end

        puts 'Done!'
      end
    end
  end
end