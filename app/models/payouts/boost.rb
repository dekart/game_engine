module Payouts
  class Boost < Base
    def value=(value)
      @value = value.is_a?(::Boost) ? value.id : value.to_i
    end

    def amount=(value)
      @amount = value.to_i
    end

    def amount
      @amount || 1
    end

    def boost
      ::Boost.find_by_id(value)
    end

    def apply(character, reference = nil)
      if action == :remove
        character.purchased_boosts.take!(boost, amount)
      else
        character.purchased_boosts.give!(boost, amount)
      end
    end
  end
end
