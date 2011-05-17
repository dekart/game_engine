class Fight
  module ResultCalculator
    module Proportion
      def calculate_attacker_victory
        attack_points   = attacker.attack_points
        defence_points  = victim.defence_points
        attack_bonus    = 1.0
        defence_bonus   = 1.0

        attack = attack_points * attack_bonus * 50
        defence = defence_points * defence_bonus * 50

        attacker_won = (rand((attack + defence).to_i) >= defence)

        attacker_won
      end
    end
  end
end
