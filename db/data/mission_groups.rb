
          GameData::MissionGroup.define :tutorial do |g|
            
          end
        

          GameData::MissionGroup.define :adventurer do |g|
            
        g.requires do |r|
          r.level = 2

        end
      
          end
        

          GameData::MissionGroup.define :recruit do |g|
            
        g.requires do |r|
          r.level = 5

        end
      
          end
        
