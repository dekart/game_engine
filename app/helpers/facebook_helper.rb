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

  def invite_dialog(type, options = {})
    callback = options.delete(:callback)
    before = options.delete(:before)
    
    "".tap do |result|
      result << ga_track_event('Requests', "#{ type.to_s.titleize } - Dialog").to_s
      result << before.to_s
      result << "InviteDialog.show('#{ type }', #{ options.to_json }, function(){ #{ callback } });"
      
      result.gsub!(/\n\s+/, ' ')
    end.html_safe!
  end
end
