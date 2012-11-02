class FixPositions < ActiveRecord::Migration
  def up
    [ItemGroup, MissionGroup].each do |klass|
      klass.with_state(:deleted).select{|obj| obj.position}.each do |obj|
        obj.update_attribute(:position, nil)
      end

      objects = klass.without_state(:deleted).sort_by{|obj| obj.position }
      i = 1

      objects.each do |obj|
        obj.update_attribute(:position, i)
        i += 1
      end
    end

    Mission.with_state(:deleted).select{|obj| obj.position}.each do |obj|
      obj.update_attribute(:position, nil)
    end

    MissionGroup.without_state(:deleted).each do |group|
      missions = group.missions.without_state(:deleted).sort_by{|obj| obj.position }
      i = 1

      missions.each do |obj|
        obj.update_attribute(:position, i)
        i += 1
      end
    end
  end

  def down
  end
end
