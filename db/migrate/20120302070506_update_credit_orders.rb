class UpdateCreditOrders < ActiveRecord::Migration
  def up
    number = CreditOrder.update_all(["state = ?", :placed], ["state = ?", :settled])
    puts "Changed state to 'placed' for #{number} Credit Orders"
  end

  def down
  end
end
