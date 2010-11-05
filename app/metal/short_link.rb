class ShortLink
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/cil\/(.+)/
      target_url = "http://apps.facebook.com/%s/invitations/%s?reference=invite_link" % [
        Facebooker2.canvas_page_name,
        $1
      ]

      [
        200, {"Content-Type" => "text/html"},
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
      ]
    else
      [404, {"Content-Type" => "text/html"}, "Not Found"]
    end
  end
end
