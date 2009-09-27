class Character
  module HelpRequests
    def can_publish?
      latest_request = self.latest

      latest_request.nil? or latest_request.expired?
    end
  end
end