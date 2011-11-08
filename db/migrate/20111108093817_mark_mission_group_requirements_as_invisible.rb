class MarkMissionGroupRequirementsAsInvisible < ActiveRecord::Migration
  def self.up
    MissionGroup.transaction do
      MissionGroup.all.each do |group|
        next if group.requirements.empty?
      
        group.requirements.each do |req|
          req.visible = false
        end
        
        group.save!
      end
    end
  end

  def self.down
    MissionGroup.transaction do
      MissionGroup.all.each do |group|
        next if group.requirements.empty?
      
        group.requirements.each do |req|
          req.visible = true
        end
      
        group.save!
      end
    end
  end
end
