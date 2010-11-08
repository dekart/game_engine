module Facebooker2
  module Rails
    module Helpers
      module FacebookConnect
        #
        # Render an <fb:login-button> element, similar to
        # fb_login_button. Adds a js redirect to the onlogin event via rjs.
        #
        # ==== Examples
        #
        #   fb_login_and_redirect '/other_page'
        #   => <fb:login-button onlogin="window.location.href = &quot;/other_page&quot;;"></fb:login-button>
        #
        # Like #fb_login_button, this also supports the :text option
        #
        #   fb_login_and_redirect '/other_page', :text => "Login with Facebook", :v => '2'
        #   => <fb:login-button onlogin="window.location.href = &quot;/other_page&quot;;" v="2">Login with Facebook</fb:login-button>
        #
        def fb_login_and_redirect(url, options = {})
          js = update_page do |page|
            page.redirect_to url
          end

          text = options.delete(:text)

          content_tag("fb:login-button", text, options.merge(:onlogin => js))
        end


        def fb_login(options = {}, &proc)
          js = capture(&proc)

          text = options.delete(:text)

          content_tag("fb:login-button", text, options.merge(:onlogin => js))
        end


        #
        # Logs the user out of facebook and redirects to the given URL
        #  args are passed to the call to link_to_function
        def fb_logout_link(text, url, *args)
          function = "FB.logout(function() {window.location.href = '#{url}';})"

          link_to_function(text, function, *args)
        end


        def fb_server_fbml(style = nil, &proc)
          content = capture(&proc)

          concat(
            content_tag('fb:serverFbml',
              content_tag(:script, content.html_safe, :type => 'text/fbml'),
              :style => style
            )
          )
        end
      end
    end
  end
end
