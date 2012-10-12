class AddHideUnsatisfiedToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :hide_unsatisfied, :boolean
  end
end
