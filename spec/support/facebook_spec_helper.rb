module FacebookSpecHelper
  def fake_fb_user
    mock("facebook user", 
      :uid            => 123456789,
      :authenticated? => true,
      
      :access_token   => 'faketoken',
      :access_token_expires_at => 1.hour.from_now
    )
  end
end