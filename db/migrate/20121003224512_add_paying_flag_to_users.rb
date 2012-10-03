class AddPayingFlagToUsers < ActiveRecord::Migration
  def up
    add_column :users, :paying, :boolean

    say_with_time "Updating users..." do
      character_ids = VipMoneyDeposit.connection.select_values %{
        SELECT DISTINCT(character_id)
        FROM vip_money_operations
        WHERE
          vip_money_operations.type = 'VipMoneyDeposit' AND
          vip_money_operations.reference_type IN ('offerpal', 'super_rewards', 'credits', 'paypal')
      }

      character_ids.each_slice(100) do |ids|
        User.where(
          "users.id IN (SELECT user_id FROM characters WHERE characters.id IN (?))", ids
        ).update_all "paying = 1"
      end
    end
  end

  def down
    remove_column :users, :paying
  end
end
