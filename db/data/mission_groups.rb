
          GameData::MissionGroup.define :tutorial do |g|
            
          end
        

          GameData::MissionGroup.define :adventurer do |g|
            
      g.requires do |r|
        r.level 2

      end
    
          end
        

          GameData::MissionGroup.define :recruit do |g|
            
      g.requires do |r|
        r.level 5

      end
    
          end
        

            if false # It's hidden
              
          GameData::MissionGroup.define :special do |g|
            
      g.reward_on :success do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :failure do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :repeat_success do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :repeat_failure do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :level_complete do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :mission_complete do |r|
        r.give_vip_money(1)

      end
    
      g.reward_on :mission_group_complete do |r|
        r.give_vip_money(1)

      end
    
      g.requires do |r|
        r.alliance_size 1
r.attack 1
r.character_type :warrior
r.defence 1
r.ep 1
r.vip_money 1
r.hp 1
r.item :item_6738267
r.level 1
r.basic_money 1
r.property :mine
r.sp 1

      end
    
          end
        
            end
          
