namespace :app do
  namespace :notifications do
    desc "Deliver 'friends to invite' notification"
    task :friends_to_invite => :environment do
      Jobs::Notifications::DeliverFriendsToInvite.new.perform
    end

    desc "Deliver 'send gift' notification"
    task :send_gift => :environment do
      Jobs::Notifications::DeliverSendGift.new.perform
    end
  end
end