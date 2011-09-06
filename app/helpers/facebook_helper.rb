module FacebookHelper
  def fb_fan_box(options = {})
    content_tag("fb:fan", "", {:profile_id => Facebooker2.app_id}.merge(options))
  end

  def fb_comments(xid, options = {})
    content_tag('fb:comments', '', options.merge(:xid => xid))
  end

  def fb_profile_url(user)
    "#{request.protocol}www.facebook.com/profile.php?id=#{user.facebook_id}"
  end

  def fb_app_page_url
    "#{request.protocol}www.facebook.com/apps/application.php?id=#{Facebooker2.app_id}"
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
      "
        FB.ui(%s, function(response){ 
          if(!$.isEmptyObject(response)){ 
            $('#ajax').load('%s', {ids: response.request_ids}, function(){ 
              %s; 
            });
          } 
        }); 
        
        $(document).trigger('facebook.dialog');
      " % [
        options.deep_merge(:method => 'apprequests', :data => {:type => type}).to_json,
        app_requests_path(request_params.merge(:type => type)),
        after_callback
      ]
    ).gsub(/\n\s+/, ' ')
  end
end
