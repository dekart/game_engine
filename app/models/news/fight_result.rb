module News
  class FightResult < Base
    def attacker
      @attacker ||= Character.find(data[:attacker_id])
    end

    def victim
      @victim ||= Character.find(data[:victim_id])
    end

    def won?
      data[:attacker_id] == data[:winner_id]
    end
  end
end
