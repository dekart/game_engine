module FacebookSpecHelper
  def fake_fb_user
    mock("facebook user", :id => 123456789, :client => mock("mogli client", :access_token => "fake token"))
  end
end