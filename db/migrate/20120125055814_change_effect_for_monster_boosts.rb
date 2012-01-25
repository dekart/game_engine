class ChangeEffectForMonsterBoosts < ActiveRecord::Migration
  def self.up
    Item.transaction do
      boosts = Item.all(:conditions => "boost_type is not NULL and boost_type != ''")
      
      boosts.each do |boost|
        if (health = boost.effect(:health)) and health > 0
          
          boost.effects = Effects::Collection.new.tap do |result|
            boost.effects.each do |effect|
              result << effect unless effect.name == "health"
            end
            
            result << Effects::Damage.new(:value => health)
          end
          
          boost.save
        end
      end
    end
  end

  def self.down
  end
end
