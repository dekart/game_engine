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
    before_callback = options.delete(:before)
    after_callback  = options.delete(:callback)
    request_params  = options.delete(:params) || {}
        
    if_fb_connect_initialized(
      "
        %s;
        FB.ui(%s, function(response){ 
          if(!$.isEmptyObject(response)){ 
            $('#ajax').load('%s', {ids: response.request_ids}, function(){ 
              %s; 
            });
          } 
        }); 
        
        $(document).trigger('facebook.dialog');
      " % [
        before_callback,
        options.deep_merge(:method => 'apprequests', :data => {:type => type}).to_json,
        app_requests_path(request_params.merge(:type => type)),
        after_callback
      ]
    ).gsub(/\n\s+/, ' ')
  end
  
  def fb_graph_user_image_tag(facebook_id, size, options = {})
    image_tag("http://graph.facebook.com/#{facebook_id}/picture?type=#{size}&return_ssl_resources=#{request.ssl? ? 1 : 0}", 
      options)
  end
end
