module Facepalm
  class User
    class << self
      def from_signed_request(config, input)
        return if input.blank?
        
        new(parse_signed_request(config, input))
      end
      
      # Originally provided directly by Facebook, however this has changed
      # as their concept of crypto changed. For historic purposes, this is their proposal:
      # https://developers.facebook.com/docs/authentication/canvas/encryption_proposal/
      # Currently see https://github.com/facebook/php-sdk/blob/master/src/facebook.php#L758
      # for a more accurate reference implementation strategy.
      def parse_signed_request(config, input)
        encoded_sig, encoded_envelope = input.split('.', 2)
        signature = base64_url_decode(encoded_sig).unpack("H*").first
        envelope = MultiJson.decode(base64_url_decode(encoded_envelope))

        raise "SignedRequest: Unsupported algorithm #{ envelope['algorithm'] }" unless envelope['algorithm'] == 'HMAC-SHA256'

        # now see if the signature is valid (digest, key, data)
        hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, config.secret, encoded_envelope)

        raise 'SignedRequest: Invalid signature' if (signature != hmac)

        ::Rails.logger.debug(envelope.inspect)

        envelope
      end

      def base64_url_decode(str)
        str += '=' * (4 - str.length.modulo(4))
        Base64.decode64(str.tr('-_', '+/'))
      end
    end
    
    def initialize(options = {})
      @options = options
    end
    
    def authenticated?
      uid && access_token
    end
    
    def uid
      @options['user_id']
    end
    
    def oauth_code
      @options['code']
    end
    
    def access_token
      @options['access_token'] || @options['oauth_token']
    end
    
    def access_token_expires_at
      Time.at(@options['expires'])
    end
    
    def authenticated?
      access_token && !access_token.empty?
    end
  end
end