class ShortLink
  extend ApplicationController::ReferenceCode
  
  def self.call(env)
    if match_data = env["PATH_INFO"].match(/^\/cil\/(\d+-[a-z0-9]+)/) and key = match_data[1]
      target_url = Facebooker2.canvas_page_url("#{env['rack.url_scheme']}://")

      if user_id = fetch_user_id(key)
        target_url << "/relations/%s?reference_code=%s" % [key, CGI.escape(reference_code(:invite_link, user_id))]
      end
      
      [200, {"Content-Type" => "text/html"}, iframe_redirect_code(target_url)]
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  rescue Exception => e
    [200, {"Content-Type" => "text/html"}, iframe_redirect_code(Facebooker2.canvas_page_url)]
  end

  def self.fetch_user_id(key)
    Character.find_by_invitation_key(key).try(:user_id)
  end

  def self.iframe_redirect_code(target_url)
    %{
      <html><head>
        <script type="text/javascript">
          window.top.location.href = #{target_url.to_json};
        </script>
        <noscript>
          <meta http-equiv="refresh" content="0;url=#{target_url}" />
          <meta http-equiv="window-target" content="_top" />
        </noscript>
      </head></html>
    }
  end
end
