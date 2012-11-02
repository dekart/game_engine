class DeleteOldInformationNotifications < ActiveRecord::Migration
  def up
    Message.update_all("state = 'hidden'", "state not in ('hidden', 'visible', 'deleted')")

    puts "Deleting information notification for #{Character.count} characters..."
    i = 0

    Character.find_in_batches(:batch_size => 100) do |characters|
      characters.each do |character|
        $redis.hdel("notifications_#{character.id}", "information")

        i += 1
        puts "Processed #{i}..." if i % 100 == 0
      end
    end
    puts "Done!"
  end

  def down
  end
end
