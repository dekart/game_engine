module Payouts
  class Mercenary < Base
    attr_reader :mercenaries

    def value=(value)
      @value = value.to_i
    end

    def apply(character)
      @mercenaries = []

      @value.times do
        if self.action == :remove
          if mercenary = character.mercenary_relations.first
            mercenary.destroy
          end

          @mercenaries << mercenary
        else
          @mercenaries << character.mercenary_relations.create
        end
      end
    end
  end
end