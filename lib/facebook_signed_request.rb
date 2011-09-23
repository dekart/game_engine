module FacebookSignedRequest
  include Facebooker2::SignedRequest
  
  def generate_signed_request(user)
    access_data = generate_access_data(user)

    encoded = Base64.encode64(
      access_data.to_json
    ).gsub(/=*\n?$/, "").gsub(/\n/, "")

    sig = Base64.encode64(
      HMAC::SHA256.digest(Facebooker2.secret, encoded)
    ).gsub(/=*\n?$/, "").gsub(/\n/, "").tr("+/", "-_")

    "#{sig}.#{encoded}"
  end

  def generate_access_data(user)
    {
        "algorithm" => "HMAC-SHA256",
        "expires"   => user.access_token_expire_at.to_i,
        "issued_at" => user.last_visit_at.to_i,
        "oauth_token"=> user.access_token,
        "user_id"   => user.facebook_id,
        "user" => {
          "locale" => user.locale
        }
    }
  end
  
  def extract_user_id(request)
    signed_request = request.cookies["fbsr_#{Facebooker2.app_id}"]
    signed_request ||= request.env['HTTP_SIGNED_REQUEST']
    
    fb_decode_signed_request(signed_request)[:user_id] if signed_request
  end
  
  def extract_character(request)
    user_id = extract_user_id(request)
    
    User.find_by_facebook_id(user_id).try(:character) if user_id
  end
end
