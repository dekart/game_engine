class Fight
  module ResultCalculator
    class Base
      attr_reader :attacker, :victim
      
      def initialize(attacker, victim)
        @attacker = attacker
        @victim = victim
      end
      
      # Determines the winner. Should be re-defined in subclasses.
      def calculate
        true
      end
    end
  end
end