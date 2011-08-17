module Notification
  class ContestWinner < Base
    def contest
      @contest ||= ::Contest.find(data[:contest_id])
    end
    
    def contest_payouts
      contest.payouts_for(character)
    end
    
    def contest_position
      contest.position(character)
    end
  end
end