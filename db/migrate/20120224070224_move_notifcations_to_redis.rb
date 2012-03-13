class MoveNotifcationsToRedis < ActiveRecord::Migration
  def up
    puts "Moving disabled notifications to redis..."

    result = ActiveRecord::Base.connection.execute "SELECT character_id, type from notifications where state='disabled'"

    result.each do |char_id, type|
      type = type.split("::").last.underscore

      $redis.hset("notifications_#{char_id}", type, "false")
    end

    drop table :notifications
  end

  def down
  end
end
