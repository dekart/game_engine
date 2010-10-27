module Facebooker2
  module Rails
    module Controller
      module CanvasOAuth
        def facebook_oauth_connect
          raise "Canvas page name not defined! Define it in config/facebooker.yml as #{::Rails.env}: canvas_page_name: <your url>." if !Facebooker2.canvas_page_name

          if params[:error]
            raise Facebooker2::OAuthException.new(params[:error][:message])
          else
            # this is where you get a code for requesting an access_token to do additional OAuth requests
            # outside of using the FB JavaScript library (see Authenticating Users in a Web Application
            # under the Authentication docs at http://developers.facebook.com/docs/authentication/)
            if params[:code]
              redirect_to 'http://apps.facebook.com/%s%s' % [
                Facebooker2.canvas_page_name,
                params[:return_to]
              ]

              false
            else
              raise Facebooker2::OAuthException.new('No code returned.')
            end
          end
        end

        protected
        
          def ensure_canvas_connected(*scope)
            if current_facebook_user == nil && !params[:code] && !params[:error]
              url = 'https://graph.facebook.com/oauth/authorize?client_id=%s&redirect_uri=%s&scope=%s' % [
                Facebooker2.app_id,
                facebook_oauth_connect_url(:return_to => request.request_uri),
                scope.join(',')
              ]

              redirect_from_iframe(url)

              false
            end
          end
      end
    end
  end
end
