module Facebooker2
  module Rails
    module Helpers
      module Javascript
        def fb_concat(str)
          if ::Rails::VERSION::STRING.to_i > 2
            str
          else
            concat(str)
          end
        end


        def fb_html_safe(str)
          if str.respond_to?(:html_safe)
            str.html_safe
          else
            str
          end
        end


        def fb_connect_async_js(app_id = Facebooker2.app_id, options = {}, &proc)
          opts    = Hash.new(true).merge!(options)
          cookie  = opts[:cookie]
          status  = opts[:status]
          xfbml   = opts[:xfbml]
          locale  = options[:locale] || "en_US"

          extra_js = capture(&proc) if block_given?

          js = <<-JAVASCRIPT
          <script>
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{app_id}',
                status : #{status}, // check login status
                cookie : #{cookie}, // enable cookies to allow the server to access the session
                xfbml  : #{xfbml}  // parse XFBML
              });
              #{extra_js}
            };

            (function() {
              var s = document.createElement('div');
              s.setAttribute('id','fb-root');
              document.documentElement.getElementsByTagName("body")[0].appendChild(s);
              var e = document.createElement('script');
              e.src = document.location.protocol + '//connect.facebook.net/#{locale}/all.js';
              e.async = true;
              s.appendChild(e);
            }());
          </script>
          JAVASCRIPT

          js = fb_html_safe(js)

          block_given? ? fb_concat(js) : js
        end
      end
    end
  end
end
