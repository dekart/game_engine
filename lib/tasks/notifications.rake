namespace :app do
  namespace :notifications do
    desc "Deliver 'friends to invite' notification"
    task :friends_to_invite => :environment do
      Character.find_each(:batch_size => 1) do |character|
        friend_ids = character.friend_filter.for_invitation(6)
        
        character.notifications.schedule(:friends_to_invite, :friend_ids => friend_ids) unless friend_ids.empty?
      end
    end
  end
end