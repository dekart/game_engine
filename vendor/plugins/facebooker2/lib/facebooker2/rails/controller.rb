require "digest/md5"
require "hmac-sha2"

module Facebooker2
  module Rails
    module Controller

      def self.included(controller)
        controller.send(:include, CanvasOAuth)
        controller.send(:include, UrlRewriting)

        controller.helper Facebooker2::Rails::Helpers
        controller.helper_method :current_facebook_user
        controller.helper_method :current_facebook_client
        controller.helper_method :facebook_params
        controller.helper_method :facebook_signed_request
        controller.helper_method :facebook_canvas_page_url
        controller.helper_method :facebook_callback_url
      end


      def current_facebook_user
        fetch_client_and_user

        @_current_facebook_user
      end


      def current_facebook_client
        fetch_client_and_user

        @_current_facebook_client
      end
      
      # This mimics the getSession logic from the php facebook SDK
      # https://github.com/facebook/php-sdk/blob/master/src/facebook.php#L333
      #
      def fetch_client_and_user
        return if @_fb_user_fetched
        
        # Try to authenticate from the signed request first
        sig = fetch_client_and_user_from_signed_request
        sig = fetch_client_and_user_from_cookie if @_current_facebook_client.nil? and !signed_request_from_logged_out_user?
        
        #write the authentication params to a new cookie
        if !@_current_facebook_client.nil? 
          #we may have generated the signature based on the params in @facebook_params, and the expiration here is different
          
          set_fb_cookie(@_current_facebook_client.access_token, @_current_facebook_client.expiration, @_current_facebook_user.id, sig)
        else
          # if we do not have a client, delete the cookie
          set_fb_cookie(nil,nil,nil,nil)
        end
        
        @_fb_user_fetched = true
      end


      def fetch_client_and_user_from_cookie
        hash_data = fb_cookie_hash
        
        if hash_data and fb_cookie_signature_correct?(fb_cookie_hash, Facebooker2.secret)
          fb_create_user_and_client(
            hash_data["access_token"],
            hash_data["expires"],
            hash_data["uid"]
          )
          
          fb_cookie_hash["sig"]
        end
      end
      
      def fb_create_user_and_client(token, expires, user_id)
        client = Mogli::Client.new(token, expires.to_i)
        user = Mogli::User.new(:id => user_id)
        
        fb_sign_in_user_and_client(user, client)
      end


      def fb_sign_in_user_and_client(user, client)
        user.client = client

        @_current_facebook_user = user
        @_current_facebook_client = client
        @_fb_user_fetched = true
      end
      
      def fb_cookie_hash
        return nil unless fb_cookie?
        
        hash = {}
        
        data = fb_cookie.gsub(/"/, "")
        
        data.split("&").each do |str|
          parts = str.split("=")
          
          hash[parts.first] = parts.last
        end
        
        hash
      end
      
      def fb_cookie?
        !fb_cookie.nil?
      end
      
      def fb_cookie
        cookies[fb_cookie_name]
      end
      
      def fb_cookie_name
        "fbs_#{Facebooker2.app_id}"
      end
      
      # check if the expected signature matches the one from facebook
      def fb_cookie_signature_correct?(hash, secret)
        generate_signature(hash, secret) == hash["sig"]
      end
      
      # If the signed request is valid but contains no oauth token,
      # the user is either logged out from Facebook or has not authorized the app
      def signed_request_from_logged_out_user?
        !facebook_params.empty? && facebook_params[:oauth_token].nil?
      end
      
      # compute the md5 sig based on access_token,expires,uid, and the app secret
      def generate_signature(hash, secret)
        sorted_keys = hash.keys.reject {|k| k == "sig" }.sort
        test_string = ""

        sorted_keys.each do |key|
          test_string << "#{key}=#{hash[key]}"
        end

        test_string << secret
        
        Digest::MD5.hexdigest(test_string)
      end


      def fb_signed_request_json(encoded)
        chars_to_add = 4 - (encoded.size % 4)

        encoded += ("=" * chars_to_add)

        Base64.decode64(encoded)
      end


      def facebook_params
        @facebook_param ||= fb_load_facebook_params
      end
      
      def params_without_facebook_data
        params.except(:signed_request)
      end


      def facebook_signed_request
        params[:signed_request] || request.env['HTTP_SIGNED_REQUEST']
      end


      def fb_load_facebook_params
        signed_request = facebook_signed_request

        return {} if signed_request.blank?

        sig, encoded_json = signed_request.split(".")

        return {} unless fb_signed_request_sig_valid?(sig, encoded_json)

        ActiveSupport::JSON.decode(fb_signed_request_json(encoded_json)).with_indifferent_access
      end


      def fb_signed_request_sig_valid?(sig, encoded)
        base64 = Base64.encode64(
          HMAC::SHA256.digest(Facebooker2.secret, encoded)
        )

        #now make the url changes that facebook makes
        url_escaped_base64 = base64.gsub(/=*\n?$/, "").tr("+/", "-_")

        sig == url_escaped_base64
      end


      def fetch_client_and_user_from_signed_request
        if facebook_params[:oauth_token]
          fb_create_user_and_client(
            facebook_params[:oauth_token],
            facebook_params[:expires],
            facebook_params[:user_id]
          )
          
          if @_current_facebook_client
            #compute a signature so we can store it in the cookie
            sig_hash = {
              "uid"           => facebook_params[:user_id],
              "access_token"  => facebook_params[:oauth_token],
              "expires"       => facebook_params[:expires]
            }
            
            generate_signature(sig_hash, Facebooker2.secret)
          end
        end
      end
      
      
      # /**
      #   This method was shamelessly stolen from the php facebook SDK:
      #   https://github.com/facebook/php-sdk/blob/master/src/facebook.php
      #   
      #    Set a JS Cookie based on the _passed in_ session. It does not use the
      #    currently stored session -- you need to explicitly pass it in.
      #   
      #   If a nil access_token is passed in this method will actually delete the fbs_ cookie
      #
      #   */
      def set_fb_cookie(access_token,expires,uid,sig) 
        
        #default values for the cookie
        value = 'deleted'
        expires = Time.now.utc - 3600 unless expires != nil

        # If the expires value is set to some large value in the future, then the 'offline access' permission has been
        # granted.  In the Facebook JS SDK, this causes a value of 0 to be set for the expires parameter.  This value 
        # needs to be correct otherwise the request signing fails, so if the expires parameter retrieved from the graph
        # api is more than a year in the future, then we set expires to 0 to match the JS SDK.
        expires = 0 if expires > Time.now + 1.year
        
        if access_token
          # Retrieve the existing cookie data
          data = fb_cookie_hash || {}
          # Remove the deleted value if this has previously been set, as we don't want to include it as part of the 
          # request signing parameters
          data.delete('deleted') if data.key?('deleted')
          # Keep existing cookie data that could have been set by FB JS SDK
          data.merge!('access_token' => access_token, 'uid' => uid, 'sig' => sig, 'expires' => expires.to_i.to_s)
          # Create string to store in cookie
          value = '"'
          data.each do |k,v|
            value += "#{k.to_s}=#{v.to_s}&"
          end
          value.chop!
          value+='"'
        end
  
        # if an existing cookie is not set, we dont need to delete it
        if (value == 'deleted' && (!fb_cookie? || fb_cookie == "" ))
          return;
        end
        
        #My browser doesn't seem to save the cookie if I set expires
        cookies[fb_cookie_name] = { :value=>value }#, :expires=>expires}
      end
      
    
      # For canvas apps, You need to set the p3p header in order to get IE 6/7 to accept the third-party cookie
      # For details http://www.softwareprojects.com/resources/programming/t-how-to-get-internet-explorer-to-use-cookies-inside-1612.html
      def set_p3p_header_for_third_party_cookies
        response.headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'
      end
      
      
      def facebook_canvas_page_url
        Facebooker2.canvas_page_url(request.protocol)
      end
      
      def facebook_callback_url
        Facebooker2.callback_url(request.protocol)
      end
      

      # Appends facebook signed_request to params on redirect
      def redirect_to(options = {}, response_status = {})
        unless facebook_signed_request.blank?
          case options
          when String
            # append signed_request param to query string
            uri = URI.parse(options)
            uri.query = (uri.query ? "#{uri.query}&"  : "") + "signed_request=#{facebook_signed_request}"
            options = uri.to_s
          when Hash
            options[:signed_request] ||= facebook_signed_request
          end
        end
        
        super(options, response_status)
      end

      def redirect_from_iframe(url_options)
        redirect_url = url_options.is_a?(String) ? url_options : url_for(url_options)
        
        logger.info "Redirecting from IFRAME to #{redirect_url}"

        render :layout => false, :text => <<-HTML
          <html><head>
            <script type="text/javascript">
              window.top.location.href = #{redirect_url.to_json};
            </script>
            <noscript>
              <meta http-equiv="refresh" content="0;url=#{redirect_url}" />
              <meta http-equiv="window-target" content="_top" />
            </noscript>
          </head></html>
        HTML
      end
    end
  end
end
