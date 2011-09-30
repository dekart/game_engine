module FacebookHelper
  def fb_fan_box(options = {})
    content_tag("fb:fan", "", {:profile_id => facepalm.app_id}.merge(options))
  end

  def fb_comments(xid, options = {})
    content_tag('fb:comments', '', options.merge(:xid => xid))
  end

  def fb_profile_pic(user, options = {})
    options[:title] ||= options[:alt]
    
    image_tag(
      'https://graph.facebook.com/%s/picture?type=%s&return_ssl_resources=%d' % [
        user.respond_to?(:facebook_id) ? user.facebook_id : user, 
        options[:size],
        request.ssl? ? 1 : 0
      ], 
      :alt    => options[:alt] || '',
      :title  => options[:title] || ''
    )
  end
  
  def fb_name(user, options = {})
    content_tag('fb:name', '', options.merge(:uid => user.respond_to?(:facebook_id) ? user.facebook_id : user))
  end

  def fb_profile_url(user)
    "#{request.protocol}www.facebook.com/profile.php?id=#{user.facebook_id}"
  end

  def fb_app_page_url
    "#{request.protocol}www.facebook.com/apps/application.php?id=#{facepalm.app_id}"
  end

  def if_fb_connect_initialized(command = nil, &block)
    command = capture(&block) if block_given?
    
    result = "if(typeof FB !== 'undefined'){ #{command}; }else{ alert('The page failed to initialize properly. Please reload it and try again.'); }"
    result = result.html_safe
    
    block_given? ? concat(result) : result
  end
  
  def fb_request_dialog(type, options = {})
    after_callback  = options.delete(:callback)
    request_params  = options.delete(:params) || {}
        
    if_fb_connect_initialized(
      %(
        %s;
        FB.ui(%s, function(response){
          if(response !== null){
            $('#ajax').load('%s', $.extend({request_id: response.request, to: response.to}, %s), function(){ 
              %s; 
            });
          }
        }); 
        
        $(document).trigger('facebook.dialog');
      ) % [
        ga_track_event('Requests', "#{type.to_s.titleize} - Dialog"),
        options.deep_merge(:method => 'apprequests', :data => {:type => type}).to_json,
        app_requests_path,
        request_params.merge(:type => type).to_json,
        after_callback
      ]
    ).gsub(/\n\s+/, ' ')
  end
end
