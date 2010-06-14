class Character
  module HelpRequests
    def can_publish?(context)
      latest_request = latest(
        context.is_a?(String) ? context.classify.constantize : context.class
      )

      latest_request.nil? or latest_request.expired?
    end
  end
end