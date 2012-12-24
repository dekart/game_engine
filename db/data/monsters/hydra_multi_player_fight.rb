
          GameData::MonsterType.define :hydra_multi_player_fight do |m|
            
        m.tags = [:multiplayer]
      
        m.level = 3
      
        m.fight_time = 12.hours
        m.respawn_time = 24.hours

        m.health = 100

        m.damage = 1..5
        m.response = 1..5

        m.reward_collectors = 5
      
          m.effects = {:attack=>1, :defence=>1}
        
      m.reward_on :victory do |r|
        r.give_vip_money(1)
r.give_basic_money(200)

      end
    
      m.reward_on :repeat_victory do |r|
        r.give_basic_money(200)

      end
    
      m.reward_on :attack do |r|
        
          r.give_experience 1
          r.give_basic_money 5
        
      end
    
          end
        
