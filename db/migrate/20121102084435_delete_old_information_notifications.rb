class DeleteOldInformationNotifications < ActiveRecord::Migration
  def up
    Message.update_all("state = 'hidden'", "state not in ('hidden', 'visible', 'deleted')")

    puts "Deleting information notification for #{Character.count} characters..."

    i = 0
    keys = $redis.keys("notifications_*")

    keys.each do |key|
      $redis.hdel(key, "information")

      i += 1
      puts "Processed #{i}..." if i % 100 == 0
    end

    puts "Done!"
  end

  def down
  end
end
