module FacebookSignedRequest
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
end
