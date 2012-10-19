class MakeBinaryFieldForFriendList < ActiveRecord::Migration
  def up
    add_column :users, :new_friend_ids, :binary

    User.reset_column_information

    say_with_time "Updating users (#{ User.count } total)..." do
      i = 0

      User.find_in_batches do |users|
        say "Users #{ users.first.id } - #{ users.last.id } (#{ i } processed)", true

        User.transaction do
          users.each do |user|
            user[:new_friend_ids] = user[:friend_ids].split(',').map{|id| id.to_i }.pack('Q*') unless user[:friend_ids].blank?

            user.save!
          end
        end

        i += users.size
      end
    end

    remove_column :users, :friend_ids
    rename_column :users, :new_friend_ids, :friend_ids
  end

  def down
    add_column :users, :old_friend_ids, :text

    User.reset_column_information

    say_with_time "Reverting users (#{ User.count } total)..." do
      i = 0

      User.find_in_batches do |users|
        say "Users #{ users.first.id } - #{ users.last.id } (#{ i } processed)", true

        User.transaction do
          users.each do |user|
            user[:old_friend_ids] = user[:friend_ids].unpack('Q*').join(',') unless user[:friend_ids].nil?

            user.save!
          end
        end

        i += users.size
      end
    end

    remove_column :users, :friend_ids
    rename_column :users, :old_friend_ids, :friend_ids
  end
end
