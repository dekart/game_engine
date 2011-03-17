class Fight
  module ResultCalculator
    class Base
      attr_reader :attacker, :victim
      
      def initialize(attacker, victim)
        @attacker = attacker
        @victim = victim
      end
    end
  end
end