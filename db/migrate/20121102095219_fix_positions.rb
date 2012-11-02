class FixPositions < ActiveRecord::Migration
  def up
    [ItemGroup, MissionGroup, Mission].each do |klass|

      klass.with_state(:deleted).select{|obj| obj.position}.each do |obj|
        klass.update_all(
          "position = (position - 1)", "state != \'deleted\' AND position > #{obj.position}"
        )
        obj.update_attribute(:position, nil)
      end
    end
  end

  def down
  end
end
