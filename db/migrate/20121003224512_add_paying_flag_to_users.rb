class AddPayingFlagToUsers < ActiveRecord::Migration
  def up
    add_column :users, :paying, :boolean

    say_with_time "Updating users..." do
      User.update_all "paying = 1", %{
        users.id IN (
          SELECT DISTINCT(characters.user_id)
          FROM vip_money_operations
          LEFT JOIN characters ON (characters.id = vip_money_operations.character_id)
          WHERE
            vip_money_operations.type = 'VipMoneyDeposit' AND
            vip_money_operations.reference_type IN ('offerpal', 'super_rewards', 'credits', 'paypal')
        )
      }
    end
  end

  def down
    remove_column :users, :paying
  end
end
