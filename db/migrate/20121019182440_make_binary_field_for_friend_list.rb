class MakeBinaryFieldForFriendList < ActiveRecord::Migration
  def up
    add_column :users, :new_friend_ids, :binary

    User.reset_column_information

    say "Updating users (#{ User.count } total)..." do
      User.find_in_batches do |users|
        say "Users #{ users.first.id } - #{ users.last.id }"
        User.transaction do
          users.each do |user|
            user[:new_friend_ids] = user[:friend_ids].split(',').map{|id| id.to_i }.pack('Q*')

            user.save!
          end
        end
      end
    end

    rename_column :users, :friend_ids, :old_friend_ids
    rename_column :users, :new_friend_ids, :friend_ids
  end

  def down
  end
end
