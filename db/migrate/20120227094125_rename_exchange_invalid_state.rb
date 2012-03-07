class RenameExchangeInvalidState < ActiveRecord::Migration
  def up
    Exchange.update_all("state = 'failed'", :state => 'invalid')
  end

  def down
    Exchange.update_all("state = 'invalid'", :state => 'failed')
  end
end
