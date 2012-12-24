
          GameData::PropertyType.define :windmill do |p|
            
        p.tags = [:shop]
      
        p.upgrades = 2000

        p.collect_period = 1.hours
      
        p.requires_for :build do |r|
          r.basic_money(200)

        end
      
      p.reward_on :build do |r|
        r.take_basic_money(200)
r.take_vip_money(0)

      end
    
        p.requires_for :upgrade do |r|
          r.basic_money(200 + 100 * r.reference.level)

        end
      
      p.reward_on :upgrade do |r|
        r.take_basic_money(200 + 100 * r.reference.level)
r.take_vip_money(0)

      end
    
      p.reward_on :collect do |r|
        
            r.give_basic_money 5 * r.reference.level
          
      end
    
          end
        
