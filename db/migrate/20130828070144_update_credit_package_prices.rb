class UpdateCreditPackagePrices < ActiveRecord::Migration
  def up
    CreditPackage.update_all "price = price * 10 + 5"
  end

  def down
    CreditPackage.update_all "price = price / 10"
  end
end
