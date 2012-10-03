class AddPayingFlagToUsers < ActiveRecord::Migration
  def up
    add_column :users, :paying, :boolean

    User.update_all %{
      paying = IF(
        (
          SELECT COUNT(*)
          FROM vip_money_operations
          LEFT JOIN characters ON (characters.id = vip_money_operations.character_id)
          WHERE
            characters.user_id = users.id AND
            vip_money_operations.type = 'VipMoneyDeposit' AND
            vip_money_operations.reference_type IN ('offerpal', 'super_rewards', 'credits', 'paypal')
        ) > 0,
        1,
        0
      )
    }
  end

  def down
    remove_column :users, :paying
  end
end
