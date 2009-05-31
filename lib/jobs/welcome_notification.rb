module Jobs
  class WelcomeNotification < Struct.new(:user_id)
    include Common

    def perform
      return unless user = User.find_by_id(user_id)

      facebook_session.send_notification([user],
        "<fb:ref url=\"#{app_path("pages/welcome_notification")}\" />"
      )
    end
  end
end