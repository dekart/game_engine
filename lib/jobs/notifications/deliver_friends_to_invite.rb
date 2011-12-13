module Jobs
  module Notifications
    class DeliverFriendsToInvite
      def perform
        Setting[:notifications_friends_to_invite_displayed_at] = Time.now

        total = Character.count

        puts "Scheduling friend invitation notifications to #{total} characters..."

        i = 0

        Character.find_each(:batch_size => 1) do |character|
          friend_ids = character.friend_filter.for_invitation(15)

          unless friend_ids.empty? || ENV['NEW_ONLY'] && character.notifications.by_type(:friends_to_invite).any?
            character.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids)
          end

          i += 1

          puts "Processed #{i} of #{total}..." if i % 100 == 0
        end

        puts 'Done!'
      end
    end
  end
end