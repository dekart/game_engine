module Facebooker2
  module SignedRequest
    def fb_signed_request_json(encoded)
      chars_to_add = 4 - (encoded.size % 4)

      encoded += ("=" * chars_to_add)

      Base64.decode64(encoded)
    end


    def fb_signed_request_sig_valid?(sig, encoded)
      base64 = Base64.encode64(
        HMAC::SHA256.digest(Facebooker2.secret, encoded)
      )
      
      #now make the url changes that facebook makes
      url_escaped_base64 = base64.gsub(/=*\n?$/, "").tr("+/", "-_")

      sig == url_escaped_base64
    end

    def fb_decode_signed_request(signed_request)
      return {} if signed_request.blank?

      sig, encoded_json = signed_request.split(".")

      return {} unless fb_signed_request_sig_valid?(sig, encoded_json)

      ActiveSupport::JSON.decode(fb_signed_request_json(encoded_json)).with_indifferent_access
    end
  end
end