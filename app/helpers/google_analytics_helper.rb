module GoogleAnalyticsHelper
  def google_analytics
    return unless ga_enabled?
    
    %{
      <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{ Setting.s(:app_google_analytics_id) }']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = 'http://www.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
      </script>
    }.html_safe
  end
  
  def ga_enabled?
    !Setting.s(:app_google_analytics_id).blank?
  end

  def ga_track_event(category, action, label = nil, value = nil)
    return unless ga_enabled?
    
    value = value.to_i
    
    ga_command('_trackEvent', category, action, label, value > 0 ? value : nil)
  end
  
  def ga_command(*args)
    "_gaq.push(#{args.compact.to_json});".html_safe
  end
end