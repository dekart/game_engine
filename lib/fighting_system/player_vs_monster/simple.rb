module FightingSystem
  module PlayerVsMonster
    module Simple
      class << self
        def calculate_damage(character, monster)
          [
            calculate_damage_for(monster.effect(:attack), character.defence_points, monster.minimum_response, monster.maximum_response),
            calculate_damage_for(character.attack_points, monster.effect(:defence), monster.monster_type.damage.begin, monster.monster_type.damage.end)
          ]
        end

        def calculate_damage_for(attack, defence, min_damage, max_damage)
          attack = 1 if attack == 0
          defence = 1 if defence == 0

          percentage = attack.to_f / (attack + defence)

          if percentage < 0.1
            percentage = 0.1
          elsif percentage > 1
            percentage = 1
          end

          from = ((max_damage - min_damage) * (percentage - 0.1) * 1000).round
          to = ((max_damage - min_damage) * (percentage + 0.1) * 1000).round

          result = min_damage + ((rand(to - from) + from) * 0.001).round

          if result < min_damage
            min_damage
          elsif result > max_damage
            max_damage
          else
            result
          end
        end
      end
    end
  end
end