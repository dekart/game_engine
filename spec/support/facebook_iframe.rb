module Facebooker
  module Rails
    module TestHelpers
      def default_facebook_parameters
        {
          :fb_sig_added => "1",
          :fb_sig_session_key => "facebook_session_key",
          :fb_sig_user => "1234",
          :fb_sig_expires => "0",
          :fb_sig_in_canvas => "1",
          :fb_sig_time => Time.now.to_f,

          :fb_sig_in_iframe => 1
        }
      end
    end
  end
end