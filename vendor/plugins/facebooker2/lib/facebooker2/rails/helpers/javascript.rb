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


        def fb_connect_async_js(*args, &proc)
          options = args.extract_options!
          
          app_id  = args.shift || Facebooker2.app_id

          options.reverse_merge!(
            :wrap_tag => true,
            :cookie   => true,
            :status   => true,
            :xfbml    => true,
            :locale   => "en_US"
          )

          extra_js = capture(&proc) if block_given?

          js = <<-JAVASCRIPT
            window.fbAsyncInit = function() {
              FB.init({
                appId  : '#{app_id}',
                status : #{options[:status]}, // check login status
                cookie : #{options[:cookie]}, // enable cookies to allow the server to access the session
                xfbml  : #{options[:xfbml]},  // parse XFBML
                channelUrl : '#{ options[:channel_url] || 'null' }'
              });
              #{extra_js}
            };

            (function() {
              var s = document.createElement('div');
              s.setAttribute('id','fb-root');
              document.documentElement.getElementsByTagName("body")[0].appendChild(s);
              var e = document.createElement('script');
              e.src = document.location.protocol + '//connect.facebook.net/#{options[:locale]}/all.js';
              e.async = true;
              s.appendChild(e);
            }());
          JAVASCRIPT

          js = javascript_tag(js) if options[:wrap_tag]
          js = fb_html_safe(js)

          block_given? ? fb_concat(js) : js
        end
      end
    end
  end
end
