namespace :app do
  namespace :import do
    desc "Import missions and mission groups"
    task :missions, :file_path, :needs => :environment do |t, options|
      require 'csv'
      
      if File.file?(options.file_path)
        data = CSV.parse(File.read(options.file_path))
        
        data.shift(2) # Skipping header rows
        
        current_group = nil
        current_mission = nil
        
        Mission.transaction do
          data.each do |row|
            next if row.compact.empty?
          
            if row[0].present? # Mission Group
              current_group = MissionGroup.new(
                :name => row[0]
              )
              
              if row[1].to_i > 0
                current_group.requirements = Requirements::Collection.new(
                  Requirements::Level.new(:value => row[1])
                )
              end
              
              current_group.save!
              current_group.publish!
            elsif row[3].present? # Mission
              current_mission = current_group.missions.build(
                :name => row[3],
                :description => row[4]
              )
              
              current_mission.save!
              current_mission.publish!
            elsif row[6].present? # MissionLevel
              level = current_mission.levels.build(
                :win_amount => row[6],
                :money_min  => row[7],
                :money_max  => row[8],
                :energy     => row[9],
                :experience => row[10]
              )
              
              level.save!
            end
          end
        end
      else
        puts "File not found: #{ options.file_path }"
      end
    end
  end
end