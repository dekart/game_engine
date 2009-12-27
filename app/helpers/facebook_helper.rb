module FacebookHelper
  def fb_app_name(options = {:linked => false})
    tag("fb:application-name", options)
  end

  def fb_header(text, options = {})
    content_tag("fb:header", text, options.reverse_merge(:icon => false))
  end

  def fb_date(date, format, options = {})
    date = date.to_time unless date.is_a?(DateTime)

    tag("fb:date",
      options.merge(
        :t => date.to_i,
        :format => format
      )
    )
  end

  def fb_wallpost_action(text, link)
    content_tag("fb:wallpost-action", text, :href => link)
  end

  def fb_if_section_not_added(section, &block)
    concat(
      content_tag("fb:if-section-not-added", capture(&block), :section => section)
    )
  end

  def fb_custom_multi_friend_selector(*args, &block)
    if block_given?
      options = {:showborder => false, :max => 20}.merge(args.extract_options!)

      concat(
        content_tag("fb:multi-friend-selector", capture(&block), options)
      )
    else
      fb_multi_friend_selector(*args, &block)
    end
  end

  def fb_profile_url(user)
    "http://www.facebook.com/profile.php?id=#{user.facebook_id}"
  end

  def fb_app_page_url
    "http://www.facebook.com/apps/application.php?api_key=#{Facebooker.facebooker_config["api_key"]}"
  end

  def fb_app_requests_url
    "http://www.facebook.com/reqs.php#confirm_#{Facebooker.facebooker_config["app_id"]}_0"
  end

  def fb_i(*args, &block)
    options = args.extract_options!

    tag = content_tag("fb:intl", "#{args.shift} #{capture(&block) if block_given?}", options)

    block_given? ? concat(tag) : tag
  end

  def fb_it(name, *args, &block)
    fb_named_tag("intl-token", name, *args, &block)
  end

  def fb_fa(name, *args, &block)
    fb_named_tag("fbml-attribute", name, *args, &block)
  end

  def fb_tag(name, *args, &block)
    fb_named_tag("tag", name, *args, &block)
  end

  def fb_ta(name, *args, &block)
    fb_named_tag("tag-attribute", name, *args, &block)
  end

  def fb_js_string(name, content = nil, &block)
    if block_given?
      output_buffer << content_tag("fb:js-string", capture(&block), :var => name)
    else
      content_tag("fb:js-string", content, :var => name)
    end
  end

  def confirm_javascript_function(confirm, fun = nil)
    if !respond_to?(:request_comes_from_facebook?) || !request_comes_from_facebook?
      confirm_javascript_function_without_facebooker(confirm)
    else
      if(confirm.is_a?(Hash))
        confirm_options = confirm.stringify_keys
		    title = confirm_options.delete("title") || "Please Confirm"
		    content = confirm_options.delete("content") || "Are you sure?"
		    button_confirm = confirm_options.delete("button_confirm") || "Okay"
		    button_cancel = confirm_options.delete("button_cancel") || "Cancel"
		    style = confirm_options.empty? ? "" : convert_options_to_css(confirm_options)
	    else
	      title,content,style,button_confirm,button_cancel = 'Please Confirm', confirm, "", "Okay", "Cancel"
	    end

      js_key = "confirm_#{confirm.object_id}"

      output_buffer << fb_js_string(js_key + "content", content)
      output_buffer << fb_js_string(js_key + "title", title)
      output_buffer << fb_js_string(js_key + "button_confirm", button_confirm)
      output_buffer << fb_js_string(js_key + "button_cancel", button_cancel)

      "var dlg = new Dialog().showChoice(#{js_key + "title"},#{js_key + "content"},#{js_key + "button_confirm"},#{js_key + "button_cancel"}).setStyle(#{style});"+
	    "var a=this;dlg.onconfirm = function() { #{fun ? fun : 'document.setLocation(a.getHref());'} };"
	  end
  end

  def fb_chat_invite(message, condensed = false, *exclude_ids)
    content_tag("fb:chat-invite", "",
      :msg          => message,
      :condensed    => (condensed || nil),
      :exclude_ids  => (exclude_ids.any? ? exclude_ids.join(",") : nil)
    )
  end

  protected

  def fb_named_tag(tag, name, *args, &block)
    options = args.extract_options!.merge(:name => name)
    tag = content_tag("fb:#{tag}", block_given? ? capture(&block): args.shift, options)

    block_given? ? concat(tag) : tag
  end
end