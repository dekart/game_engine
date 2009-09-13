module Payouts
  class Mercenary < Base
    attr_reader :mercenaries

    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      if self.action == :remove and mercenary = character.mercenary_relations.first
        mercenary.destroy
      else
        @mercenaries = []
        
        @value.times do
          @mercenaries << character.mercenary_relations.create
        end
      end
    end
  end
end