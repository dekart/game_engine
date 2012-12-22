module Notification
  class ContestFinished < Base
    def contest
      @contest ||= ::Contest.find(data[:contest_id])
    end

    def contest_position
      contest.position(character)
    end
  end
end