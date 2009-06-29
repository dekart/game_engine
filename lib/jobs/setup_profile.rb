module Jobs
  class SetupProfile < Struct.new(:user_id)
    include Jobs::Common

    def perform
      Facebooker::Session.current = facebook_session

      user = User.find(user_id)

      Facebooker::User.new(user.facebook_id).profile_fbml = <<-CODE
        <fb:narrow>
          <fb:ref url="#{app_path("users/" + user.id.to_s + "/narrow_profile_box.fbml")}" />
        </fb:narrow>
        <fb:wide>
          <fb:ref url="#{app_path("users/" + user.id.to_s + "/wide_profile_box.fbml")}" />
        </fb:wide>
      CODE

      Facebooker::User.new(user.facebook_id).profile_main = <<-CODE
        <fb:ref url="#{app_path("users/" + user.id.to_s + "/narrow_profile_box.fbml")}" />
      CODE
    end
  end
end